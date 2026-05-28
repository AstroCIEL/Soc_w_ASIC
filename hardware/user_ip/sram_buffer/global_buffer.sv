//////////////////////////////////////////////////////////////////////////////////
// global_buffer: 4 × sramsp_4096_64 (4096×64b SP SRAM) in one address space.
//
//   Total capacity : 4 × 4096 × 8 B = 128 KiB
//   Single shared port — connect to axi2mem (req/we/addr/be/wdata → rdata).
//
//   Byte address map (AXI_ADDR_WIDTH, 64-bit beats):
//     [16:15] bank select (2 bits)
//     [14:3]  word index inside bank (12 bits, 8-byte aligned)
//     [2:0]   byte-in-beat (must be 0 for axi2mem)
//
//   sramsp_4096_64 has no per-bit write mask; axi_byte_en_i is accepted for
//   axi2mem compatibility but only full 64-bit writes are performed.
//////////////////////////////////////////////////////////////////////////////////

module global_buffer #(
    parameter int AXI_ADDR_WIDTH  = 64,
    parameter int AXI_DATA_WIDTH  = 64,
    parameter int NUM_BANKS       = 4,
    parameter int BANK_WORDS      = 4096,
    parameter int BANK_ADDR_WIDTH = $clog2(BANK_WORDS),  // 12
    parameter int CS_WIDTH        = $clog2(NUM_BANKS)    // 2
) (
    input  logic                          clk_i,
    input  logic                          rstn_i,

    // axi2mem memory port
    input  logic                          axi_req_i,
    input  logic                          axi_write_en_i,
    input  logic [AXI_ADDR_WIDTH-1:0]     axi_addr_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]   axi_byte_en_i,
    input  logic [AXI_DATA_WIDTH-1:0]     axi_wdata_i,
    output logic [AXI_DATA_WIDTH-1:0]     axi_rdata_o
);

    localparam int CS_W            = (CS_WIDTH > 0) ? CS_WIDTH : 1;
    localparam int AXI_ADDR_OFFSET = $clog2(AXI_DATA_WIDTH / 8);

    logic [CS_W-1:0]                        axi_cs_from_addr;
    logic [CS_W-1:0]                        axi_cs_q;
    logic [BANK_ADDR_WIDTH-1:0]             axi_bank_addr;

    logic [NUM_BANKS-1:0]                   bank_en;
    logic [NUM_BANKS-1:0][BANK_ADDR_WIDTH-1:0] bank_addr;
    logic [NUM_BANKS-1:0][AXI_DATA_WIDTH-1:0]  bank_wdata;
    logic [NUM_BANKS-1:0]                   bank_gwen;
    logic [NUM_BANKS-1:0][AXI_DATA_WIDTH-1:0]  bank_rdata;

    // -------------------------------------------------------------------------
    // AXI address decode
    // -------------------------------------------------------------------------
    assign axi_bank_addr = axi_addr_i[AXI_ADDR_OFFSET + BANK_ADDR_WIDTH - 1 -: BANK_ADDR_WIDTH];

    generate
        if (CS_WIDTH > 0) begin : gen_axi_cs_from_addr
            assign axi_cs_from_addr =
                axi_addr_i[AXI_ADDR_OFFSET + CS_WIDTH + BANK_ADDR_WIDTH - 1 -: CS_WIDTH];
        end else begin : gen_axi_cs_from_addr_zero
            assign axi_cs_from_addr = '0;
        end
    endgenerate

    // Register bank select on read (aligns with sramsp_4096_64 read latency).
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            axi_cs_q <= '0;
        end else if (axi_req_i && !axi_write_en_i) begin
            axi_cs_q <= axi_cs_from_addr;
        end
    end

    assign axi_rdata_o = (NUM_BANKS == 1) ? bank_rdata[0] : bank_rdata[axi_cs_q];

    // -------------------------------------------------------------------------
    // Per-bank enable / address / write data
    // -------------------------------------------------------------------------
    generate
        if (NUM_BANKS == 1) begin : gen_single_bank_drive
            assign bank_en[0]    = axi_req_i;
            assign bank_addr[0]  = axi_bank_addr;
            assign bank_wdata[0] = axi_wdata_i;
            assign bank_gwen[0]  = ~axi_write_en_i;  // 0 = write, 1 = read
        end else begin : gen_multi_bank_drive
            always_comb begin
                bank_en    = '0;
                bank_addr  = '0;
                bank_wdata = '0;
                bank_gwen  = {NUM_BANKS{1'b1}};

                for (int unsigned m = 0; m < NUM_BANKS; m++) begin
                    if (axi_req_i && ($unsigned(axi_cs_from_addr) == m)) begin
                        bank_en[m]    = 1'b1;
                        bank_addr[m]  = axi_bank_addr;
                        bank_wdata[m] = axi_wdata_i;
                        bank_gwen[m]  = ~axi_write_en_i;  // 0 = write, 1 = read
                    end
                end
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // sramsp_4096_64 instances (active-low cen; gwen 0=write 1=read)
    // -------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < NUM_BANKS; i++) begin : gen_bank
            wire cen_n = ~bank_en[i];
            sramsp_4096_64 u_bank (
                .q     ( bank_rdata[i]  ),
                .clk   ( clk_i          ),
                .cen   ( cen_n          ),
                .gwen  ( bank_gwen[i]   ),
                .a     ( bank_addr[i]   ),
                .d     ( bank_wdata[i]  ),
                .stov  ( 1'b0           ),
                .ema   ( 3'b100         ), //推荐值
                .emaw  ( 2'b01          ), //推荐值
                .emas  ( 1'b0           ), //推荐值
                .ret1n ( 1'b1           ),
                .rawl  ( 1'b0           ),
                .rawlm ( 2'b00          ),
                .wabl  ( 1'b1           ),//开启vmin_assist
                .wablm ( 2'b00          )
            );
        end
    endgenerate

    // Suppress unused (no byte-write mask in macro).
    logic unused_byte_en;
    assign unused_byte_en = |axi_byte_en_i;

endmodule
