//////////////////////////////////////////////////////////////////////////////////
// Description:     SRAM wrapper for sram_1024_64_lx (1024 words x 64 bits).
//                  Interface compatible with axi2mem; 64-bit matches AXI data width.
//                  Default: NUM_MACROS = 1. sram_1024_64_lx has Write Mask Off (whole-word write).
//////////////////////////////////////////////////////////////////////////////////

module sram_1024_64_wrapper #(
    parameter int AXI_ADDR_WIDTH    = 64,
    parameter int AXI_DATA_WIDTH    = 64,
    parameter int AXI_ADDR_OFFSET   = 3,     // 8-byte alignment (64 bit = 8 B)
    parameter int NUM_MACROS        = 1,
    parameter int MACRO_ADDR_WIDTH  = 10,
    parameter int CS_WIDTH          = $clog2(NUM_MACROS)
) (
    input  logic                                    clk_i,
    input  logic                                    rstn_i,

    // axi2mem interface
    input  logic                                    axi_req_i,
    input  logic                                    axi_write_en_i,
    input  logic [  AXI_ADDR_WIDTH-1:0]             axi_addr_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]             axi_byte_en_i,
    input  logic [  AXI_DATA_WIDTH-1:0]             axi_wdata_i,
    output logic [  AXI_DATA_WIDTH-1:0]             axi_rdata_o
);
    localparam int CS_W = (CS_WIDTH > 0) ? CS_WIDTH : 1;
    logic [AXI_DATA_WIDTH-1:0]                      main_mem_wdata;
    logic [NUM_MACROS-1:0]                          main_mem_en;
    logic [NUM_MACROS-1:0]                          main_mem_wen;
    logic [MACRO_ADDR_WIDTH-1:0]                    main_mem_addr;
    logic [NUM_MACROS-1:0][AXI_DATA_WIDTH-1:0]     main_mem_rdata;

    logic                                           axi_req_d;
    // logic                                           axi_req_q;
    // logic [CS_W-1:0]                            axi_cs_q, 
    logic [CS_W-1:0]                               axi_cs_d;

    // Chip-select from address. Use generate so part select is only compiled when CS_WIDTH > 0 ([x -: 0] is illegal).
    logic [CS_W-1:0] axi_cs_from_addr;
    generate
        if (CS_WIDTH > 0)
            assign axi_cs_from_addr = axi_addr_i[AXI_ADDR_OFFSET+CS_WIDTH+MACRO_ADDR_WIDTH-1 -: CS_WIDTH];
        else
            assign axi_cs_from_addr = '0;
    endgenerate

    always_comb begin
        axi_req_d = 1'b0;
        axi_cs_d  = 1'b0;
        if (axi_req_i) begin
            axi_req_d = 1'b1;
            axi_cs_d  = axi_cs_from_addr;
        end
    end

    // always_ff @(posedge clk_i or negedge rstn_i) begin
    //     if (!rstn_i) begin
    //         axi_req_q <= 1'b0;
    //         axi_cs_q  <= '0;
    //     end else begin
    //         axi_req_q <= axi_req_d;
    //         axi_cs_q  <= axi_cs_d;
    //     end
    // end

    assign axi_rdata_o = (NUM_MACROS == 1) ? main_mem_rdata[0] : main_mem_rdata[axi_cs_d]; //从axi_cs_q改成axi_cs_d,不多打这一拍。依然要等两个周期才能读到有效数据

    always_comb begin : generate_en
        main_mem_en = '0;
        if (axi_req_i) begin
            if (CS_WIDTH == 0)
                main_mem_en[0] = 1'b1;
            else
                main_mem_en[axi_cs_from_addr] = 1'b1;
        end
    end

    always_comb begin : generate_wen
        main_mem_wen = '0;
        if (axi_req_i) begin
            if (CS_WIDTH == 0)
                main_mem_wen[0] = axi_write_en_i;
            else
                main_mem_wen[axi_cs_from_addr] = axi_write_en_i;
        end
    end

    always_comb begin : generate_addr
        main_mem_addr = '0;
        if (axi_req_i)
            main_mem_addr = axi_addr_i[AXI_ADDR_OFFSET+MACRO_ADDR_WIDTH-1 -: MACRO_ADDR_WIDTH];
    end

    always_comb begin : generate_wdata
        main_mem_wdata = '0;
        if (axi_req_i)
            main_mem_wdata = axi_wdata_i;
    end

    // sram_1024_64_lx: Write Mask Off — whole 64-bit word write only; axi_byte_en_i not used by macro.

    genvar i;
    generate
        for (i = 0; i < NUM_MACROS; i++) begin : gen_main_mem
            sram_1024_64_lx main_mem_inst (
                .q     ( main_mem_rdata[i]   ),
                .clk   ( clk_i               ),
                .cen   ( ~main_mem_en[i]     ), //cen低有效
                .gwen  ( ~main_mem_wen[i]    ), //gwen低有效
                .a     ( main_mem_addr       ),
                .d     ( main_mem_wdata      ),
                .stov  ( 1'b0                ),
                .ema   ( 3'b111              ),
                .emaw  ( 2'b11                ),
                .emas  ( 1'b1                ),
                .ret1n ( 1'b1                )
            );
        end
    endgenerate

endmodule
