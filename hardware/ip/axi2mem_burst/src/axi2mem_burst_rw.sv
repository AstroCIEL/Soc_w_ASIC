
`include "axi/assign.svh"
`include "axi/typedef.svh"

module axi2mem_burst_rw #(
    parameter int unsigned AXI_ID_WIDTH   = 10,
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_USER_WIDTH = 1,
    /// Depth of internal response buffer (should match memory read latency).
    parameter int unsigned BufDepth       = 1
) (
    input  logic                          clk_i,
    input  logic                          rst_ni,
    AXI_BUS.Slave                         slave,
    output logic                          req_o,
    output logic                          we_o,
    output logic [AXI_ADDR_WIDTH-1:0]     addr_o,
    output logic [AXI_DATA_WIDTH/8-1:0]   be_o,
    output logic [AXI_USER_WIDTH-1:0]     user_o,
    output logic [AXI_DATA_WIDTH-1:0]     data_o,
    input  logic [AXI_USER_WIDTH-1:0]     user_i,
    input  logic [AXI_DATA_WIDTH-1:0]     data_i
);

    // NumMemPorts = 2 * AXI_DATA_WIDTH / MEM_DATA_WIDTH.
    // With MEM_DATA_WIDTH == AXI_DATA_WIDTH: NumMemPorts = 2 (one R, one W).
    localparam int unsigned NumMemPorts = 2;

    // Wires between axi_to_mem_split_intf and the arbiter.
    // axi_to_mem_split_intf uses packed multi-dimensional ports:
    //   addr_t [N-1:0] => logic [N-1:0][AddrWidth-1:0]
    logic [NumMemPorts-1:0]                        mem_req;
    logic [NumMemPorts-1:0]                        mem_gnt;
    logic [NumMemPorts-1:0][AXI_ADDR_WIDTH-1:0]    mem_addr;
    logic [NumMemPorts-1:0][AXI_DATA_WIDTH-1:0]    mem_wdata;
    logic [NumMemPorts-1:0][AXI_DATA_WIDTH/8-1:0]  mem_strb;
    logic [NumMemPorts-1:0][5:0]                   mem_atop;
    logic [NumMemPorts-1:0]                        mem_we;
    logic [NumMemPorts-1:0]                        mem_rvalid;
    logic [NumMemPorts-1:0][AXI_DATA_WIDTH-1:0]    mem_rdata;

    axi_to_mem_split_intf #(
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH   ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH ),
        .MEM_DATA_WIDTH ( AXI_DATA_WIDTH ), // same width => 2 ports (R+W)
        .BUF_DEPTH      ( BufDepth       ),
        .HIDE_STRB      ( 1'b0           ),
        .OUT_FIFO_DEPTH ( 1              )
    ) i_axi_split (
        .clk_i,
        .rst_ni,
        .test_i      ( 1'b0        ),
        .busy_o      ( /* unused */ ),
        .axi_bus     ( slave       ),
        .mem_req_o   ( mem_req     ),
        .mem_gnt_i   ( mem_gnt     ),
        .mem_addr_o  ( mem_addr    ),
        .mem_wdata_o ( mem_wdata   ),
        .mem_strb_o  ( mem_strb    ),
        .mem_atop_o  ( mem_atop    ),
        .mem_we_o    ( mem_we      ),
        .mem_rvalid_i( mem_rvalid  ),
        .mem_rdata_i ( mem_rdata   )
    );

    // ----------------------------------------------------------------
    // Burst-sticky arbiter: merges 2 mem ports => 1 SRAM port
    // Port 0 = read port (index 0 from split), Port 1 = write port (index 1)
    // ----------------------------------------------------------------
    mem_rw_arb #(
        .AddrWidth ( AXI_ADDR_WIDTH ),
        .DataWidth ( AXI_DATA_WIDTH )
    ) i_arb (
        .clk_i,
        .rst_ni,
        // Port 0 - read
        .p0_req_i    ( mem_req[0]   ),
        .p0_gnt_o    ( mem_gnt[0]   ),
        .p0_addr_i   ( mem_addr[0]  ),
        .p0_wdata_i  ( mem_wdata[0] ),
        .p0_strb_i   ( mem_strb[0]  ),
        .p0_we_i     ( mem_we[0]    ),
        .p0_rvalid_o ( mem_rvalid[0]),
        .p0_rdata_o  ( mem_rdata[0] ),
        // Port 1 - write
        .p1_req_i    ( mem_req[1]   ),
        .p1_gnt_o    ( mem_gnt[1]   ),
        .p1_addr_i   ( mem_addr[1]  ),
        .p1_wdata_i  ( mem_wdata[1] ),
        .p1_strb_i   ( mem_strb[1]  ),
        .p1_we_i     ( mem_we[1]    ),
        .p1_rvalid_o ( mem_rvalid[1]),
        .p1_rdata_o  ( mem_rdata[1] ),
        // SRAM
        .mem_req_o   ( req_o        ),
        .mem_we_o    ( we_o         ),
        .mem_addr_o  ( addr_o       ),
        .mem_be_o    ( be_o         ),
        .mem_wdata_o ( data_o       ),
        .mem_rdata_i ( data_i       )
    );

    // user_o not driven by the split path; tie to zero.
    assign user_o = '0;

endmodule
