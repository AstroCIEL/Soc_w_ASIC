//////////////////////////////////////////////////////////////////////////////////
// Description:     Wrapper for rf2p_512_64xn_bank (1R1W dual-port SRAM bank).
//                  NUM_BANKS instances are placed in series to expand address space.
//                  Each bank contains NUM_SRAMS rf2p_512_64 macros placed side-by-side
//                  to widen the data bus.
//
//                  Interface compatible with axi2mem; data width = BANK_DATA_WIDTH.
//                  Also provides per-bank accelerator local direct R/W ports.
//
//                  acc_sram_sel_i = 1'b0 : axi2mem interface accesses all banks.
//                  acc_sram_sel_i = 1'b1 : accelerator local ports access all banks.
//
//                  Both the read port (Port A) and write port (Port B) are switched
//                  simultaneously by acc_sram_sel_i.
//
//                  No write mask; rf2p_512_64 always writes the full BANK_DATA_WIDTH word.
//                  axi_byte_en_i is kept for axi2mem interface compatibility only.
//////////////////////////////////////////////////////////////////////////////////

module zzc_rf2p_wrapper #(
    parameter int AXI_ADDR_WIDTH  = 64,
    parameter int NUM_SRAMS       = 2,                          // macros per bank (data-width expansion)
    parameter int SRAM_DATA_WIDTH = 64,
    parameter int BANK_DATA_WIDTH = NUM_SRAMS * SRAM_DATA_WIDTH,
    parameter int AXI_ADDR_OFFSET = $clog2(BANK_DATA_WIDTH / 8),// byte-alignment offset
    parameter int NUM_BANKS       = 8,                          // number of banks (address-space expansion)
    parameter int BANK_ADDR_WIDTH = 9,                          // 2^9 = 512 words per bank
    parameter int CS_WIDTH        = $clog2(NUM_BANKS)
) (
    input  logic                                           clk_i,
    input  logic                                           rstn_i,

    // SRAM access select
    // 1'b0: axi2mem interface owns all banks (read + write ports)
    // 1'b1: accelerator local interface owns all banks (read + write ports)
    input  logic                                           acc_sram_sel_i,

    // axi2mem interface
    input  logic                                           axi_req_i,
    input  logic                                           axi_write_en_i,
    input  logic [    AXI_ADDR_WIDTH-1:0]                  axi_addr_i,
    input  logic [BANK_DATA_WIDTH/8-1:0]                   axi_byte_en_i,    // compatibility only, unused by macro
    input  logic [  BANK_DATA_WIDTH-1:0]                   axi_wdata_i,
    output logic [  BANK_DATA_WIDTH-1:0]                   axi_rdata_o,

    // Accelerator local interface (per-bank, independent R/W, flattened)
    //
    // Read port:
    //   bank m address = acc_rd_addr_i[m*BANK_ADDR_WIDTH +: BANK_ADDR_WIDTH]
    //   bank m rdata   = acc_rd_data_o[m*BANK_DATA_WIDTH +: BANK_DATA_WIDTH]
    //
    // Write port:
    //   bank m address = acc_wr_addr_i[m*BANK_ADDR_WIDTH +: BANK_ADDR_WIDTH]
    //   bank m wdata   = acc_wr_data_i[m*BANK_DATA_WIDTH +: BANK_DATA_WIDTH]
    //
    // Addresses are word addresses inside each bank, not byte addresses.
    input  logic [                NUM_BANKS-1:0]           acc_rd_req_i,
    input  logic [NUM_BANKS*BANK_ADDR_WIDTH-1:0]           acc_rd_addr_i,
    output logic [NUM_BANKS*BANK_DATA_WIDTH-1:0]           acc_rd_data_o,

    input  logic [                NUM_BANKS-1:0]           acc_wr_req_i,
    input  logic [NUM_BANKS*BANK_ADDR_WIDTH-1:0]           acc_wr_addr_i,
    input  logic [NUM_BANKS*BANK_DATA_WIDTH-1:0]           acc_wr_data_i
);

    localparam int CS_W = (CS_WIDTH > 0) ? CS_WIDTH : 1;

    // -------------------------------------------------------------------------
    // Internal accelerator local interface, unflattened
    // -------------------------------------------------------------------------
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

    logic [CS_W-1:0]                             axi_cs_from_addr;
    logic [CS_W-1:0]                             axi_cs_q;
    logic [BANK_ADDR_WIDTH-1:0]                  axi_bank_addr;

    // -------------------------------------------------------------------------
    // Flattened accelerator port mapping
    // -------------------------------------------------------------------------
    genvar p;
    generate
        for (p = 0; p < NUM_BANKS; p++) begin : gen_acc_port_flatten
            assign acc_rd_addr[p] = acc_rd_addr_i[p*BANK_ADDR_WIDTH +: BANK_ADDR_WIDTH];
            assign acc_wr_addr[p] = acc_wr_addr_i[p*BANK_ADDR_WIDTH +: BANK_ADDR_WIDTH];
            assign acc_wr_data[p] = acc_wr_data_i[p*BANK_DATA_WIDTH +: BANK_DATA_WIDTH];

            assign acc_rd_data_o[p*BANK_DATA_WIDTH +: BANK_DATA_WIDTH] = bank_rd_data[p];
        end
    endgenerate

    // -------------------------------------------------------------------------
    // AXI address decode
    // -------------------------------------------------------------------------
    assign axi_bank_addr = axi_addr_i[AXI_ADDR_OFFSET+BANK_ADDR_WIDTH-1 -: BANK_ADDR_WIDTH];

    generate
        if (CS_WIDTH > 0) begin : gen_axi_cs_from_addr
            assign axi_cs_from_addr = axi_addr_i[AXI_ADDR_OFFSET+CS_WIDTH+BANK_ADDR_WIDTH-1 -: CS_WIDTH];
        end else begin : gen_axi_cs_from_addr_zero
            assign axi_cs_from_addr = '0;
        end
    endgenerate

    // Register AXI chip-select for read-data mux (aligns with SRAM read latency).
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            axi_cs_q <= '0;
        end else if (!acc_sram_sel_i && axi_req_i && !axi_write_en_i) begin
            axi_cs_q <= axi_cs_from_addr;
        end
    end

    // -------------------------------------------------------------------------
    // AXI read data output
    // -------------------------------------------------------------------------
    assign axi_rdata_o = (NUM_BANKS == 1) ? bank_rd_data[0] : bank_rd_data[axi_cs_q];

    // -------------------------------------------------------------------------
    // Generate bank control signals
    //
    // acc_sram_sel_i = 0 (AXI mode):
    //   axi2mem issues either a read or a write to one selected bank.
    //   AXI read  (axi_write_en=0) -> drive read  port of selected bank.
    //   AXI write (axi_write_en=1) -> drive write port of selected bank.
    //   Read and write are mutually exclusive per AXI transaction.
    //
    // acc_sram_sel_i = 1 (accelerator mode):
    //   Each bank's read and write ports are controlled independently.
    //   acc_rd_req_i[m] gates the read  port of bank m.
    //   acc_wr_req_i[m] gates the write port of bank m.
    //   Simultaneous read and write to the same or different banks is allowed
    //   (true 1R1W benefit).
    // -------------------------------------------------------------------------
    always_comb begin : gen_bank_ctrl
        bank_rd_en   = '0;
        bank_rd_addr = '0;
        bank_wr_en   = '0;
        bank_wr_addr = '0;
        bank_wr_data = '0;

        for (int unsigned m = 0; m < NUM_BANKS; m++) begin
            if (acc_sram_sel_i) begin
                // Accelerator owns both ports
                if (acc_rd_req_i[m]) begin
                    bank_rd_en[m]   = 1'b1;
                    bank_rd_addr[m] = acc_rd_addr[m];
                end
                if (acc_wr_req_i[m]) begin
                    bank_wr_en[m]   = 1'b1;
                    bank_wr_addr[m] = acc_wr_addr[m];
                    bank_wr_data[m] = acc_wr_data[m];
                end
            end else begin
                // AXI owns both ports
                if (axi_req_i && ($unsigned(axi_cs_from_addr) == m)) begin
                    if (!axi_write_en_i) begin
                        bank_rd_en[m]   = 1'b1;
                        bank_rd_addr[m] = axi_bank_addr;
                    end else begin
                        bank_wr_en[m]   = 1'b1;
                        bank_wr_addr[m] = axi_bank_addr;
                        bank_wr_data[m] = axi_wdata_i;
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Instantiate rf2p_512_64xn_bank array
    // rf2p_512_64: no write mask — full BANK_DATA_WIDTH word write only.
    // -------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < NUM_BANKS; i++) begin : gen_bank
            rf2p_512_64xn_bank #(
                .NUM_SRAMS      ( NUM_SRAMS       ),
                .SRAM_ADDR_WIDTH( BANK_ADDR_WIDTH ),
                .SRAM_DATA_WIDTH( SRAM_DATA_WIDTH )
            ) u_bank (
                .rd_clk_i  ( clk_i           ),
                .rd_en_i   ( bank_rd_en[i]   ),
                .rd_addr_i ( bank_rd_addr[i] ),
                .rd_data_o ( bank_rd_data[i] ),

                .wr_clk_i  ( clk_i           ),
                .wr_en_i   ( bank_wr_en[i]   ),
                .wr_addr_i ( bank_wr_addr[i] ),
                .wr_data_i ( bank_wr_data[i] )
            );
        end
    endgenerate

endmodule
