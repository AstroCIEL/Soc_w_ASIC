// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"
`include "axi/typedef.svh"
`include "axi/assign.svh"

// Xilinx Peripherals
module ariane_peripherals #(
    parameter int           AxiAddrWidth  = -1,
    parameter int           AxiDataWidth  = -1,
    parameter int           AxiIdWidth    = -1,      // id width on peripheral (xbar-master) ports
    parameter int           AxiUserWidth  = 1,
    parameter logic [63:0]  DRAMBase      = 64'h8000_0000,
    parameter logic [63:0]  DRAMLength    = 64'h4000_0000
) (
    input  logic       clk_i           , // Clock
    input  logic       rst_ni          , // Asynchronous reset active low
    AXI_BUS.Slave      plic            ,
    AXI_BUS.Slave      uart            ,
    AXI_BUS.Slave      timer           ,
    AXI_BUS.Slave      ctrl            , // Ctrl registers @ 0xD000_0000
    AXI_BUS.Slave      default_slave   , // Default slave (mem + IRQ doorbell)
	AXI_BUS.Slave	   dcim			   ,
    output logic [1:0] irq_o           ,
    // ctrl_registers outputs
    output logic [AxiDataWidth-1:0] exit_o         ,
    output logic [AxiDataWidth-1:0] event_trigger_o,
    output logic [AxiDataWidth-1:0] hw_cnt_en_o    ,
    // UART
    input  logic       rx_i            ,
    output logic       tx_o
);

    // ---------------
    // 1. PLIC
    // ---------------
    logic [ariane_soc::NumSources-1:0] irq_sources;

    // Unused interrupt sources
    assign irq_sources[ariane_soc::NumSources-1:7] = '0;

    REG_BUS #(
        .ADDR_WIDTH ( 32 ),
        .DATA_WIDTH ( 32 )
    ) reg_bus (clk_i);

    logic         plic_penable;
    logic         plic_pwrite;
    logic [31:0]  plic_paddr;
    logic         plic_psel;
    logic [31:0]  plic_pwdata;
    logic [31:0]  plic_prdata;
    logic         plic_pready;
    logic         plic_pslverr;

    axi2apb_64_32 #(
        .AXI4_ADDRESS_WIDTH ( AxiAddrWidth  ),
        .AXI4_RDATA_WIDTH   ( AxiDataWidth  ),
        .AXI4_WDATA_WIDTH   ( AxiDataWidth  ),
        .AXI4_ID_WIDTH      ( AxiIdWidth    ),
        .AXI4_USER_WIDTH    ( AxiUserWidth  ),
        .BUFF_DEPTH_SLAVE   ( 2             ),
        .APB_ADDR_WIDTH     ( 32            )
    ) i_axi2apb_64_32_plic (
        .ACLK      ( clk_i          ),
        .ARESETn   ( rst_ni         ),
        .test_en_i ( 1'b0           ),
        .AWID_i    ( plic.aw_id     ),
        .AWADDR_i  ( plic.aw_addr   ),
        .AWLEN_i   ( plic.aw_len    ),
        .AWSIZE_i  ( plic.aw_size   ),
        .AWBURST_i ( plic.aw_burst  ),
        .AWLOCK_i  ( plic.aw_lock   ),
        .AWCACHE_i ( plic.aw_cache  ),
        .AWPROT_i  ( plic.aw_prot   ),
        .AWREGION_i( plic.aw_region ),
        .AWUSER_i  ( plic.aw_user   ),
        .AWQOS_i   ( plic.aw_qos    ),
        .AWVALID_i ( plic.aw_valid  ),
        .AWREADY_o ( plic.aw_ready  ),
        .WDATA_i   ( plic.w_data    ),
        .WSTRB_i   ( plic.w_strb    ),
        .WLAST_i   ( plic.w_last    ),
        .WUSER_i   ( plic.w_user    ),
        .WVALID_i  ( plic.w_valid   ),
        .WREADY_o  ( plic.w_ready   ),
        .BID_o     ( plic.b_id      ),
        .BRESP_o   ( plic.b_resp    ),
        .BVALID_o  ( plic.b_valid   ),
        .BUSER_o   ( plic.b_user    ),
        .BREADY_i  ( plic.b_ready   ),
        .ARID_i    ( plic.ar_id     ),
        .ARADDR_i  ( plic.ar_addr   ),
        .ARLEN_i   ( plic.ar_len    ),
        .ARSIZE_i  ( plic.ar_size   ),
        .ARBURST_i ( plic.ar_burst  ),
        .ARLOCK_i  ( plic.ar_lock   ),
        .ARCACHE_i ( plic.ar_cache  ),
        .ARPROT_i  ( plic.ar_prot   ),
        .ARREGION_i( plic.ar_region ),
        .ARUSER_i  ( plic.ar_user   ),
        .ARQOS_i   ( plic.ar_qos    ),
        .ARVALID_i ( plic.ar_valid  ),
        .ARREADY_o ( plic.ar_ready  ),
        .RID_o     ( plic.r_id      ),
        .RDATA_o   ( plic.r_data    ),
        .RRESP_o   ( plic.r_resp    ),
        .RLAST_o   ( plic.r_last    ),
        .RUSER_o   ( plic.r_user    ),
        .RVALID_o  ( plic.r_valid   ),
        .RREADY_i  ( plic.r_ready   ),
        .PENABLE   ( plic_penable   ),
        .PWRITE    ( plic_pwrite    ),
        .PADDR     ( plic_paddr     ),
        .PSEL      ( plic_psel      ),
        .PWDATA    ( plic_pwdata    ),
        .PRDATA    ( plic_prdata    ),
        .PREADY    ( plic_pready    ),
        .PSLVERR   ( plic_pslverr   )
    );

    apb_to_reg i_apb_to_reg (
        .clk_i     ( clk_i        ),
        .rst_ni    ( rst_ni       ),
        .penable_i ( plic_penable ),
        .pwrite_i  ( plic_pwrite  ),
        .paddr_i   ( plic_paddr   ),
        .psel_i    ( plic_psel    ),
        .pwdata_i  ( plic_pwdata  ),
        .prdata_o  ( plic_prdata  ),
        .pready_o  ( plic_pready  ),
        .pslverr_o ( plic_pslverr ),
        .reg_o     ( reg_bus      )
    );

    // define reg type according to REG_BUS above
    `REG_BUS_TYPEDEF_ALL(plic, logic[31:0], logic[31:0], logic[3:0])
    plic_req_t plic_req;
    plic_rsp_t plic_rsp;

    // assign REG_BUS.out to (req_t, rsp_t) pair
    `REG_BUS_ASSIGN_TO_REQ(plic_req, reg_bus)
    `REG_BUS_ASSIGN_FROM_RSP(reg_bus, plic_rsp)

    plic_top #(
      .N_SOURCE    ( ariane_soc::NumSources  ),
      .N_TARGET    ( ariane_soc::NumTargets  ),
      .MAX_PRIO    ( ariane_soc::MaxPriority ),
      .reg_req_t   ( plic_req_t              ),
      .reg_rsp_t   ( plic_rsp_t              )
    ) i_plic (
      .clk_i,
      .rst_ni,
      .req_i         ( plic_req    ),
      .resp_o        ( plic_rsp    ),
      .le_i          ( '0          ), // 0:level 1:edge
      .irq_sources_i ( irq_sources ),
      .eip_targets_o ( irq_o       )
    );

    // ---------------
    // 2. UART
    // ---------------
    logic         uart_penable;
    logic         uart_pwrite;
    logic [31:0]  uart_paddr;
    logic         uart_psel;
    logic [31:0]  uart_pwdata;
    logic [31:0]  uart_prdata;
    logic         uart_pready;
    logic         uart_pslverr;

    axi2apb_64_32 #(
        .AXI4_ADDRESS_WIDTH ( AxiAddrWidth ),
        .AXI4_RDATA_WIDTH   ( AxiDataWidth ),
        .AXI4_WDATA_WIDTH   ( AxiDataWidth ),
        .AXI4_ID_WIDTH      ( AxiIdWidth   ),
        .AXI4_USER_WIDTH    ( AxiUserWidth ),
        .BUFF_DEPTH_SLAVE   ( 2            ),
        .APB_ADDR_WIDTH     ( 32           )
    ) i_axi2apb_64_32_uart (
        .ACLK      ( clk_i          ),
        .ARESETn   ( rst_ni         ),
        .test_en_i ( 1'b0           ),
        .AWID_i    ( uart.aw_id     ),
        .AWADDR_i  ( uart.aw_addr   ),
        .AWLEN_i   ( uart.aw_len    ),
        .AWSIZE_i  ( uart.aw_size   ),
        .AWBURST_i ( uart.aw_burst  ),
        .AWLOCK_i  ( uart.aw_lock   ),
        .AWCACHE_i ( uart.aw_cache  ),
        .AWPROT_i  ( uart.aw_prot   ),
        .AWREGION_i( uart.aw_region ),
        .AWUSER_i  ( uart.aw_user   ),
        .AWQOS_i   ( uart.aw_qos    ),
        .AWVALID_i ( uart.aw_valid  ),
        .AWREADY_o ( uart.aw_ready  ),
        .WDATA_i   ( uart.w_data    ),
        .WSTRB_i   ( uart.w_strb    ),
        .WLAST_i   ( uart.w_last    ),
        .WUSER_i   ( uart.w_user    ),
        .WVALID_i  ( uart.w_valid   ),
        .WREADY_o  ( uart.w_ready   ),
        .BID_o     ( uart.b_id      ),
        .BRESP_o   ( uart.b_resp    ),
        .BVALID_o  ( uart.b_valid   ),
        .BUSER_o   ( uart.b_user    ),
        .BREADY_i  ( uart.b_ready   ),
        .ARID_i    ( uart.ar_id     ),
        .ARADDR_i  ( uart.ar_addr   ),
        .ARLEN_i   ( uart.ar_len    ),
        .ARSIZE_i  ( uart.ar_size   ),
        .ARBURST_i ( uart.ar_burst  ),
        .ARLOCK_i  ( uart.ar_lock   ),
        .ARCACHE_i ( uart.ar_cache  ),
        .ARPROT_i  ( uart.ar_prot   ),
        .ARREGION_i( uart.ar_region ),
        .ARUSER_i  ( uart.ar_user   ),
        .ARQOS_i   ( uart.ar_qos    ),
        .ARVALID_i ( uart.ar_valid  ),
        .ARREADY_o ( uart.ar_ready  ),
        .RID_o     ( uart.r_id      ),
        .RDATA_o   ( uart.r_data    ),
        .RRESP_o   ( uart.r_resp    ),
        .RLAST_o   ( uart.r_last    ),
        .RUSER_o   ( uart.r_user    ),
        .RVALID_o  ( uart.r_valid   ),
        .RREADY_i  ( uart.r_ready   ),
        .PENABLE   ( uart_penable   ),
        .PWRITE    ( uart_pwrite    ),
        .PADDR     ( uart_paddr     ),
        .PSEL      ( uart_psel      ),
        .PWDATA    ( uart_pwdata    ),
        .PRDATA    ( uart_prdata    ),
        .PREADY    ( uart_pready    ),
        .PSLVERR   ( uart_pslverr   )
    );

    apb_uart i_apb_uart (
        .CLK     ( clk_i           ),
        .RSTN    ( rst_ni          ),
        .PSEL    ( uart_psel       ),
        .PENABLE ( uart_penable    ),
        .PWRITE  ( uart_pwrite     ),
        .PADDR   ( uart_paddr[4:2] ),
        .PWDATA  ( uart_pwdata     ),
        .PRDATA  ( uart_prdata     ),
        .PREADY  ( uart_pready     ),
        .PSLVERR ( uart_pslverr    ),
        .INT     ( irq_sources[0]  ),
        .OUT1N   (                 ), // keep open
        .OUT2N   (                 ), // keep open
        .RTSN    (                 ), // no flow control
        .DTRN    (                 ), // no flow control
        .CTSN    ( 1'b0            ),
        .DSRN    ( 1'b0            ),
        .DCDN    ( 1'b0            ),
        .RIN     ( 1'b0            ),
        .SIN     ( rx_i            ),
        .SOUT    ( tx_o            )
    );

    // ---------------
    // 5. Timer
    // ---------------
    logic         timer_penable;
    logic         timer_pwrite;
    logic [31:0]  timer_paddr;
    logic         timer_psel;
    logic [31:0]  timer_pwdata;
    logic [31:0]  timer_prdata;
    logic         timer_pready;
    logic         timer_pslverr;

    axi2apb_64_32 #(
        .AXI4_ADDRESS_WIDTH ( AxiAddrWidth ),
        .AXI4_RDATA_WIDTH   ( AxiDataWidth ),
        .AXI4_WDATA_WIDTH   ( AxiDataWidth ),
        .AXI4_ID_WIDTH      ( AxiIdWidth   ),
        .AXI4_USER_WIDTH    ( AxiUserWidth ),
        .BUFF_DEPTH_SLAVE   ( 2            ),
        .APB_ADDR_WIDTH     ( 32           )
    ) i_axi2apb_64_32_timer (
        .ACLK      ( clk_i           ),
        .ARESETn   ( rst_ni          ),
        .test_en_i ( 1'b0            ),
        .AWID_i    ( timer.aw_id     ),
        .AWADDR_i  ( timer.aw_addr   ),
        .AWLEN_i   ( timer.aw_len    ),
        .AWSIZE_i  ( timer.aw_size   ),
        .AWBURST_i ( timer.aw_burst  ),
        .AWLOCK_i  ( timer.aw_lock   ),
        .AWCACHE_i ( timer.aw_cache  ),
        .AWPROT_i  ( timer.aw_prot   ),
        .AWREGION_i( timer.aw_region ),
        .AWUSER_i  ( timer.aw_user   ),
        .AWQOS_i   ( timer.aw_qos    ),
        .AWVALID_i ( timer.aw_valid  ),
        .AWREADY_o ( timer.aw_ready  ),
        .WDATA_i   ( timer.w_data    ),
        .WSTRB_i   ( timer.w_strb    ),
        .WLAST_i   ( timer.w_last    ),
        .WUSER_i   ( timer.w_user    ),
        .WVALID_i  ( timer.w_valid   ),
        .WREADY_o  ( timer.w_ready   ),
        .BID_o     ( timer.b_id      ),
        .BRESP_o   ( timer.b_resp    ),
        .BVALID_o  ( timer.b_valid   ),
        .BUSER_o   ( timer.b_user    ),
        .BREADY_i  ( timer.b_ready   ),
        .ARID_i    ( timer.ar_id     ),
        .ARADDR_i  ( timer.ar_addr   ),
        .ARLEN_i   ( timer.ar_len    ),
        .ARSIZE_i  ( timer.ar_size   ),
        .ARBURST_i ( timer.ar_burst  ),
        .ARLOCK_i  ( timer.ar_lock   ),
        .ARCACHE_i ( timer.ar_cache  ),
        .ARPROT_i  ( timer.ar_prot   ),
        .ARREGION_i( timer.ar_region ),
        .ARUSER_i  ( timer.ar_user   ),
        .ARQOS_i   ( timer.ar_qos    ),
        .ARVALID_i ( timer.ar_valid  ),
        .ARREADY_o ( timer.ar_ready  ),
        .RID_o     ( timer.r_id      ),
        .RDATA_o   ( timer.r_data    ),
        .RRESP_o   ( timer.r_resp    ),
        .RLAST_o   ( timer.r_last    ),
        .RUSER_o   ( timer.r_user    ),
        .RVALID_o  ( timer.r_valid   ),
        .RREADY_i  ( timer.r_ready   ),
        .PENABLE   ( timer_penable   ),
        .PWRITE    ( timer_pwrite    ),
        .PADDR     ( timer_paddr     ),
        .PSEL      ( timer_psel      ),
        .PWDATA    ( timer_pwdata    ),
        .PRDATA    ( timer_prdata    ),
        .PREADY    ( timer_pready    ),
        .PSLVERR   ( timer_pslverr   )
    );

    apb_timer #(
            .APB_ADDR_WIDTH ( 32 ),
            .TIMER_CNT      ( 2  )
    ) i_timer (
        .HCLK    ( clk_i            ),
        .HRESETn ( rst_ni           ),
        .PSEL    ( timer_psel       ),
        .PENABLE ( timer_penable    ),
        .PWRITE  ( timer_pwrite     ),
        .PADDR   ( timer_paddr      ),
        .PWDATA  ( timer_pwdata     ),
        .PRDATA  ( timer_prdata     ),
        .PREADY  ( timer_pready     ),
        .PSLVERR ( timer_pslverr    ),
        .irq_o   ( irq_sources[6:3] )
    );

    // ---------------
    // 6. Ctrl Registers  (0xD000_0000)
    //    AXI4-full → axi_to_axi_lite → ctrl_registers
    // ---------------

    // AXI typedefs matching the ctrl AXI_BUS port
    typedef logic [AxiAddrWidth-1:0]   ctrl_addr_t;
    typedef logic [AxiDataWidth-1:0]   ctrl_data_t;
    typedef logic [AxiDataWidth/8-1:0] ctrl_strb_t;
    typedef logic [AxiIdWidth-1:0]     ctrl_id_t;
    typedef logic [AxiUserWidth-1:0]   ctrl_user_t;

    `AXI_TYPEDEF_ALL(ctrl_full, ctrl_addr_t, ctrl_id_t, ctrl_data_t, ctrl_strb_t, ctrl_user_t)
    `AXI_LITE_TYPEDEF_ALL(ctrl_lite, ctrl_addr_t, ctrl_data_t, ctrl_strb_t)

    ctrl_full_req_t  ctrl_full_req;
    ctrl_full_resp_t ctrl_full_resp;
    ctrl_lite_req_t  ctrl_lite_req;
    ctrl_lite_resp_t ctrl_lite_resp;

    `AXI_ASSIGN_TO_REQ(ctrl_full_req, ctrl)
    `AXI_ASSIGN_FROM_RESP(ctrl, ctrl_full_resp)

    axi_to_axi_lite #(
        .AxiAddrWidth    ( AxiAddrWidth    ),
        .AxiDataWidth    ( AxiDataWidth    ),
        .AxiIdWidth      ( AxiIdWidth      ),
        .AxiUserWidth    ( AxiUserWidth    ),
        .AxiMaxReadTxns  ( 1               ),
        .AxiMaxWriteTxns ( 1               ),
        .FallThrough     ( 1'b0            ),
        .full_req_t      ( ctrl_full_req_t ),
        .full_resp_t     ( ctrl_full_resp_t),
        .lite_req_t      ( ctrl_lite_req_t ),
        .lite_resp_t     ( ctrl_lite_resp_t)
    ) i_axi_to_axi_lite_ctrl (
        .clk_i      ( clk_i          ),
        .rst_ni     ( rst_ni         ),
        .test_i     ( 1'b0           ),
        .slv_req_i  ( ctrl_full_req  ),
        .slv_resp_o ( ctrl_full_resp ),
        .mst_req_o  ( ctrl_lite_req  ),
        .mst_resp_i ( ctrl_lite_resp )
    );

    ctrl_registers #(
        .DataWidth       ( AxiDataWidth    ),
        .AddrWidth       ( AxiAddrWidth    ),
        .DRAMBaseAddr    ( DRAMBase        ),
        .DRAMLength      ( DRAMLength      ),
        .axi_lite_req_t  ( ctrl_lite_req_t ),
        .axi_lite_resp_t ( ctrl_lite_resp_t)
    ) i_ctrl_registers (
        .clk_i                 ( clk_i          ),
        .rst_ni                ( rst_ni         ),
        .axi_lite_slave_req_i  ( ctrl_lite_req  ),
        .axi_lite_slave_resp_o ( ctrl_lite_resp ),
        .exit_o                ( exit_o         ),
        .hw_cnt_en_o           ( hw_cnt_en_o    ),
        .dram_base_addr_o      (/* unused */    ),
        .dram_end_addr_o       (/* unused */    ),
        .event_trigger_o       ( event_trigger_o)
    );

    // ---------------
    // 7. Default Slave (simple mem + IRQ doorbell) @ DefaultSlaveBase
    // ---------------
    logic                     dslv_req;
    logic                     dslv_we;
    logic [AxiAddrWidth-1:0]  dslv_addr;
    logic [AxiDataWidth-1:0]  dslv_wdata;
    logic [AxiDataWidth-1:0]  dslv_rdata;

    axi2mem #(
        .AXI_ID_WIDTH   ( AxiIdWidth   ),
        .AXI_ADDR_WIDTH ( AxiAddrWidth ),
        .AXI_DATA_WIDTH ( AxiDataWidth ),
        .AXI_USER_WIDTH ( AxiUserWidth )
    ) i_axi2dslv (
        .clk_i  ( clk_i         ),
        .rst_ni ( rst_ni        ),
        .slave  ( default_slave ),
        .req_o  ( dslv_req      ),
        .we_o   ( dslv_we       ),
        .addr_o ( dslv_addr     ),
        .be_o   (               ),
        .user_o (               ),
        .data_o ( dslv_wdata    ),
        .user_i ( '0            ),
        .data_i ( dslv_rdata    )
    );

    default_slave i_default_slave (
        .clk_i     ( clk_i          ),
        .rst       ( ~rst_ni        ),
        .axi_req   ( dslv_req       ),
        .axi_we    ( dslv_we        ),
        .axi_addr  ( dslv_addr      ),
        .axi_wdata ( dslv_wdata     ),
        .axi_rdata ( dslv_rdata     ),
        .irq_o     ( irq_sources[1] )
    );

	dcim_wrap #(
		.AXI_DATA_WIDTH	( AxiDataWidth	),
		.AXI_ADDR_WIDTH	( AxiAddrWidth	)
	) i_dcim_wrap (
		.clk_i     ( clk_i          ),
        .rst       ( ~rst_ni        ),
		.axi_bus   ( dcim			)
	);

endmodule
