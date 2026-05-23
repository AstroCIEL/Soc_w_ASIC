// 8 个 256×128 的 SRAM bank 组成 buffer（可按 NUM_BANKS 配置）；每 bank 一颗 rf2p_256_128（Port A 读 / Port B 写）。
// 读口、写口归属由 acc_rd_port_sel_i / acc_wr_port_sel_i 分别控制。
//
// AXI 侧数据宽 AXI_DATA_WIDTH 可与 BANK_DATA_WIDTH 不同，要求：
//   BANK_DATA_WIDTH / AXI_DATA_WIDTH == 2^k（k>=0），仿照肖子奡Buffer.sv ：
//   - 地址：beat 内字节偏移 | 宽字内子字索引 | bank 内字地址 | bank 片选
//   - 写：wdata 广播到整行，wenb（per-bit，1=该位不写）按字节使能只开当前子字
//   - 读：锁存子字索引 + 片选，对齐 SRAM 读延迟后 mux 出 AXI_DATA_WIDTH
//
// rf2p_256_128 write口带 wenb[127:0]（1=屏蔽该位写，0=写入 db）；cenb 仍为口级写使能。

module rf2p_256_128_wrapper #(
    parameter int AXI_ADDR_WIDTH   = 64,  
    parameter int AXI_DATA_WIDTH   = 64,  // 可与 BANK_DATA_WIDTH 不同；默认与 bank 同宽
    parameter int BANK_DATA_WIDTH  = 128,  //单个SRAM BANK的位宽，可以是AXI的2的幂次倍
    parameter int NUM_BANKS        = 8,     //  BANK数目
    parameter int BANK_ADDR_WIDTH  = 8,    // rf2p_256_128：256 字=2^8
    parameter int CS_WIDTH         = $clog2(NUM_BANKS)
) (
    input  logic                                           clk_i,
    input  logic                                           rstn_i,

    // 读口(Port A)/写口(Port B)归属独立选择，与 rf2p_256_128 1R1W 一致。
    // 1'b0：该口由 axi2mem 侧（axi_*）驱动；1'b1：该口由加速器本地口（acc_*）驱动。
    input  logic                                           acc_rd_port_sel_i,
    input  logic                                           acc_wr_port_sel_i,

    // axi2mem 接口（窄于 BANK 时 wdata/be 为 AXI 宽度；rdata 同）
    input  logic                                           axi_req_i,
    input  logic                                           axi_write_en_i,
    input  logic [    AXI_ADDR_WIDTH-1:0]                  axi_addr_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]                    axi_byte_en_i,
    input  logic [  AXI_DATA_WIDTH-1:0]                   axi_wdata_i,
    output logic [  AXI_DATA_WIDTH-1:0]                   axi_rdata_o,

    input  logic [                NUM_BANKS-1:0]           acc_rd_req_i,
    input  logic [NUM_BANKS*BANK_ADDR_WIDTH-1:0]           acc_rd_addr_i,
    output logic [NUM_BANKS*BANK_DATA_WIDTH-1:0]           acc_rd_data_o,

    input  logic [                NUM_BANKS-1:0]           acc_wr_req_i,
    input  logic [NUM_BANKS*BANK_ADDR_WIDTH-1:0]           acc_wr_addr_i,
    input  logic [NUM_BANKS*BANK_DATA_WIDTH-1:0]           acc_wr_data_i
);

    localparam int CS_W = (CS_WIDTH > 0) ? CS_WIDTH : 1;

    localparam int AXI_BYTE_WIDTH = AXI_DATA_WIDTH / 8;
    localparam int RATIO_INT      = BANK_DATA_WIDTH / AXI_DATA_WIDTH; //SRAM位宽相对于AXI位宽的倍率
    localparam int LO_BANK        = $clog2(AXI_BYTE_WIDTH) + ((RATIO_INT > 1) ? $clog2(RATIO_INT) : 0);
    localparam int SUBW_W         = (RATIO_INT > 1) ? $clog2(RATIO_INT) : 1; //子词片选的地址位宽


    logic [NUM_BANKS-1:0][BANK_ADDR_WIDTH-1:0]  acc_rd_addr;
    logic [NUM_BANKS-1:0][BANK_ADDR_WIDTH-1:0]  acc_wr_addr;
    logic [NUM_BANKS-1:0][BANK_DATA_WIDTH-1:0]  acc_wr_data;

    // -------------------------------------------------------------------------
    // Bank-side control signals
    // -------------------------------------------------------------------------
    logic [NUM_BANKS-1:0]                        bank_rd_en;
    logic [NUM_BANKS-1:0][BANK_ADDR_WIDTH-1:0]   bank_rd_addr;
    logic [NUM_BANKS-1:0][BANK_DATA_WIDTH-1:0]   bank_rd_data;

    logic [NUM_BANKS-1:0]                        bank_wr_en;
    logic [NUM_BANKS-1:0][BANK_ADDR_WIDTH-1:0]   bank_wr_addr;
    logic [NUM_BANKS-1:0][BANK_DATA_WIDTH-1:0]   bank_wr_data;
    logic [NUM_BANKS-1:0][BANK_DATA_WIDTH-1:0]   bank_wr_wenb;

    logic [CS_W-1:0]                             axi_cs_from_addr;
    logic [CS_W-1:0]                             axi_cs_q;
    logic [BANK_ADDR_WIDTH-1:0]                  axi_bank_addr;
    logic [SUBW_W-1:0]                           axi_sub_word_idx;
    logic [SUBW_W-1:0]                           axi_sub_word_idx_q;

    logic [AXI_DATA_WIDTH-1:0]                   axi_bit_be;
    logic [BANK_DATA_WIDTH-1:0]                  axi_wdata_wide;
    logic [BANK_DATA_WIDTH-1:0]                  axi_wenb_wide;

    genvar p;
    generate
        for (p = 0; p < NUM_BANKS; p++) begin : gen_acc_port_flatten
            assign acc_rd_addr[p] = acc_rd_addr_i[p*BANK_ADDR_WIDTH +: BANK_ADDR_WIDTH];
            assign acc_wr_addr[p] = acc_wr_addr_i[p*BANK_ADDR_WIDTH +: BANK_ADDR_WIDTH];
            assign acc_wr_data[p] = acc_wr_data_i[p*BANK_DATA_WIDTH +: BANK_DATA_WIDTH];

            assign acc_rd_data_o[p*BANK_DATA_WIDTH +: BANK_DATA_WIDTH] = bank_rd_data[p];
        end
    endgenerate

    // AXI 字节使能 -> AXI 数据宽上的按位展开（1=该字节参与写）
    always_comb begin
        for (int bi = 0; bi < AXI_BYTE_WIDTH; bi++) begin
            axi_bit_be[bi*8 +: 8] = {8{axi_byte_en_i[bi]}};
        end
    end

    // 宽字写数据 / wenb（1=不写该位因为rf2b_256_128中是低使能）；参考 Buffer.sv
    always_comb begin
        axi_wdata_wide = '0;
        axi_wenb_wide  = {BANK_DATA_WIDTH{1'b1}};
        if (RATIO_INT > 1) begin
            axi_wdata_wide = {(RATIO_INT){axi_wdata_i}}; //把数据扩展到SRAM的位宽
            axi_wenb_wide[axi_sub_word_idx * AXI_DATA_WIDTH +: AXI_DATA_WIDTH] = ~axi_bit_be; //只把要写的位标为0（低使能）
        end else begin
            axi_wdata_wide = axi_wdata_i;
            axi_wenb_wide  = ~axi_bit_be;
        end
    end

    // 子字索引：宽字内第几个 AXI_DATA_WIDTH 片
    always_comb begin
        if (RATIO_INT > 1)
            axi_sub_word_idx = axi_addr_i[$clog2(AXI_BYTE_WIDTH) +: SUBW_W];
        else
            axi_sub_word_idx = '0;
    end

    assign axi_bank_addr = axi_addr_i[LO_BANK + BANK_ADDR_WIDTH - 1 -: BANK_ADDR_WIDTH];

    generate
        if (CS_WIDTH > 0) begin : gen_axi_cs_from_addr
            assign axi_cs_from_addr = axi_addr_i[LO_BANK + CS_WIDTH + BANK_ADDR_WIDTH - 1 -: CS_WIDTH];
        end else begin : gen_axi_cs_from_addr_zero
            assign axi_cs_from_addr = '0;
        end
    endgenerate

    // 读返回 mux：对齐 SRAM 读延迟
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            axi_cs_q            <= '0;
            axi_sub_word_idx_q  <= '0;
        end else if (!acc_rd_port_sel_i && axi_req_i && !axi_write_en_i) begin
            axi_cs_q            <= axi_cs_from_addr;
            axi_sub_word_idx_q  <= axi_sub_word_idx;
        end
    end

    logic [BANK_DATA_WIDTH-1:0] axi_rd_word;
    assign axi_rd_word = (NUM_BANKS == 1) ? bank_rd_data[0] : bank_rd_data[axi_cs_q];

    always_comb begin
        if (RATIO_INT > 1) //SRAM宽度大于AXI宽度时，选出一个AXI宽度
            axi_rdata_o = axi_rd_word[axi_sub_word_idx_q * AXI_DATA_WIDTH +: AXI_DATA_WIDTH];
        else
            axi_rdata_o = axi_rd_word[AXI_DATA_WIDTH-1:0];
    end

    // -------------------------------------------------------------------------
    // Generate bank control signals
    //
    // acc_rd_port_sel_i = 0：AXI 读路径；=1：acc_rd_req/addr 驱动读口。
    // acc_wr_port_sel_i = 0：AXI 写路径；=1：acc_wr_req/addr/data 驱动写口。
    // 两 bit 独立，可组合出 R/W 分别归 AXI 或 ACC（勿在同一口上双源驱动）。
    // -------------------------------------------------------------------------
    always_comb begin : gen_bank_ctrl
        bank_rd_en    = '0;
        bank_rd_addr  = '0;
        bank_wr_en    = '0;
        bank_wr_addr  = '0;
        bank_wr_data  = '0;
        for (int unsigned mz = 0; mz < NUM_BANKS; mz++) begin
            bank_wr_wenb[mz] = {BANK_DATA_WIDTH{1'b1}};
        end

        for (int unsigned m = 0; m < NUM_BANKS; m++) begin
            // 读口 Port A
            if (acc_rd_port_sel_i) begin
                if (acc_rd_req_i[m]) begin
                    bank_rd_en[m]   = 1'b1;
                    bank_rd_addr[m] = acc_rd_addr[m];
                end
            end else if (axi_req_i && !axi_write_en_i && ($unsigned(axi_cs_from_addr) == m)) begin
                bank_rd_en[m]   = 1'b1;
                bank_rd_addr[m] = axi_bank_addr;
            end

            // 写口 Port B
            if (acc_wr_port_sel_i) begin
                if (acc_wr_req_i[m]) begin
                    bank_wr_en[m]    = 1'b1;
                    bank_wr_addr[m]  = acc_wr_addr[m];
                    bank_wr_data[m]  = acc_wr_data[m];
                    bank_wr_wenb[m]  = '0;
                end
            end else if (axi_req_i && axi_write_en_i && ($unsigned(axi_cs_from_addr) == m)) begin
                bank_wr_en[m]    = 1'b1;
                bank_wr_addr[m]  = axi_bank_addr;
                bank_wr_data[m]  = axi_wdata_wide;
                bank_wr_wenb[m]  = axi_wenb_wide;
            end
        end
    end

    // 实例化sram, 带write mask
    genvar i;
    generate
        for (i = 0; i < NUM_BANKS; i++) begin : gen_bank
            rf2p_256_128 u_bank (
                .qa    ( bank_rd_data[i]      ),
                .clka  ( clk_i                ),
                .cena  ( ~bank_rd_en[i]       ),
                .aa    ( bank_rd_addr[i]      ),
                .clkb  ( clk_i                ),
                .cenb  ( ~bank_wr_en[i]       ),
                .wenb  ( bank_wr_wenb[i]      ),
                .ab    ( bank_wr_addr[i]      ),
                .db    ( bank_wr_data[i]      ),
                .stov  ( 1'b0                 ),
                .emaa  ( 3'b011               ),
                .emasa ( 1'b0                 ),
                .emab  ( 3'b100               ),
                .ret1n ( 1'b1                 )
            );
        end
    endgenerate

endmodule
