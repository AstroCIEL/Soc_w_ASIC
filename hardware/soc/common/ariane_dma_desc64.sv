`include "axi/typedef.svh"
`include "axi/assign.svh"
`include "register_interface/typedef.svh"
`include "idma/typedef.svh"

module ariane_dma_desc64 #(
  /// Configuration AXI slave port widths (matches SoC xbar master-port width).
  parameter int unsigned AxiCfgAddrWidth  = 64,
  parameter int unsigned AxiCfgDataWidth  = 64,
  parameter int unsigned AxiCfgIdWidth    = 4,
  parameter int unsigned AxiCfgUserWidth  = 1,
  /// Data-path AXI master port widths (drives SoC xbar slave port).
  parameter int unsigned AxiMstAddrWidth  = 64,
  parameter int unsigned AxiMstDataWidth  = 64,
  parameter int unsigned AxiMstIdWidth    = 4,
  parameter int unsigned AxiMstUserWidth  = 1,
  /// iDMA tunables
  parameter int unsigned NumAxInFlight    = 3,
  parameter int unsigned BufferDepth      = 3,
  parameter int unsigned TFLenWidth       = 32,
  parameter int unsigned MemSysDepth      = 0,
  /// desc64 frontend tunables
  parameter int unsigned InputFifoDepth   = 8,
  parameter int unsigned PendingFifoDepth = 8,
  parameter int unsigned NSpeculation     = 4,
  /// AXI type parameters (caller provides)
  parameter type         axi_cfg_req_t    = logic,
  parameter type         axi_cfg_rsp_t    = logic,
  parameter type         axi_mst_req_t    = logic,
  parameter type         axi_mst_rsp_t    = logic
) (
  input  logic            clk_i,
  input  logic            rst_ni,

  /// Config slave (CPU -> DMA registers: desc_addr + status)
  input  axi_cfg_req_t    cfg_req_i,
  output axi_cfg_rsp_t    cfg_rsp_o,

  /// Data master (DMA descriptor fetch + data R/W -> memory)
  output axi_mst_req_t    mst_req_o,
  input  axi_mst_rsp_t    mst_rsp_i,

  /// Transfer-done interrupt (directly from desc64 frontend)
  output logic            irq_o
);

  // --------------------------------------------------------------------
  // Internal widths / types
  // --------------------------------------------------------------------
  // Internal DMA AXI ID width: the axi_mux adds 1 bit to distinguish
  // the frontend (descriptor fetch) and backend (data) ports.
  // So internally both use AxiMstIdWidth - 1.
  localparam int unsigned DmaIntIdWidth = AxiMstIdWidth - 1;
  localparam int unsigned StrbWidth     = AxiMstDataWidth / 8;

  typedef logic [AxiMstAddrWidth-1:0] addr_t;
  typedef logic [AxiMstDataWidth-1:0] data_t;
  typedef logic [StrbWidth-1:0]       strb_t;
  typedef logic [AxiMstUserWidth-1:0] user_t;
  typedef logic [DmaIntIdWidth-1:0]   dma_id_t;
  typedef logic [AxiMstIdWidth-1:0]   mux_id_t;
  typedef logic [TFLenWidth-1:0]      tf_len_t;

  // AXI4 channels at internal ID width (for frontend + backend)
  `AXI_TYPEDEF_ALL(dma_axi, addr_t, dma_id_t, data_t, strb_t, user_t)

  // AXI4 channels at external (mux output) ID width
  `AXI_TYPEDEF_ALL(mux_axi, addr_t, mux_id_t, data_t, strb_t, user_t)

  // iDMA request / response
  `IDMA_TYPEDEF_FULL_REQ_T(idma_req_t, dma_id_t, addr_t, tf_len_t)
  `IDMA_TYPEDEF_FULL_RSP_T(idma_rsp_t, addr_t)

  // Backend meta-channel types
  typedef struct packed { dma_axi_ar_chan_t ar_chan; } axi_read_meta_t;
  typedef struct packed { axi_read_meta_t   axi;     } read_meta_channel_t;
  typedef struct packed { dma_axi_aw_chan_t aw_chan; } axi_write_meta_t;
  typedef struct packed { axi_write_meta_t  axi;     } write_meta_channel_t;

  // --------------------------------------------------------------------
  // AXI config slave -> 64b reg interface
  // --------------------------------------------------------------------
  typedef logic [AxiCfgAddrWidth-1:0] cfg_addr_t;
  typedef logic [AxiCfgDataWidth-1:0] cfg_data_t;
  typedef logic [AxiCfgDataWidth/8-1:0] cfg_strb_t;
  typedef logic [AxiCfgIdWidth-1:0]   cfg_id_t;
  typedef logic [AxiCfgUserWidth-1:0] cfg_user_t;

  `AXI_TYPEDEF_ALL(cfg_axi, cfg_addr_t, cfg_id_t, cfg_data_t, cfg_strb_t, cfg_user_t)

  // Spill register on cfg port to improve timing
  axi_cfg_req_t cfg_req_cut;
  axi_cfg_rsp_t cfg_rsp_cut;

  axi_multicut #(
    .NoCuts     ( 1                  ),
    .aw_chan_t  ( cfg_axi_aw_chan_t  ),
    .w_chan_t   ( cfg_axi_w_chan_t   ),
    .b_chan_t   ( cfg_axi_b_chan_t   ),
    .ar_chan_t  ( cfg_axi_ar_chan_t  ),
    .r_chan_t   ( cfg_axi_r_chan_t   ),
    .axi_req_t  ( axi_cfg_req_t     ),
    .axi_resp_t ( axi_cfg_rsp_t     )
  ) i_cfg_axi_cut (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( cfg_req_i   ),
    .slv_resp_o ( cfg_rsp_o   ),
    .mst_req_o  ( cfg_req_cut ),
    .mst_resp_i ( cfg_rsp_cut )
  );

  `REG_BUS_TYPEDEF_ALL(dma_reg, logic[AxiCfgAddrWidth-1:0],
                                logic[63:0], logic[7:0])

  dma_reg_req_t dma_reg_req_full; // full address from axi_to_reg_v2
  dma_reg_req_t dma_reg_req;      // offset-only for desc64 frontend
  dma_reg_rsp_t dma_reg_rsp;

  axi_to_reg_v2 #(
    .AxiAddrWidth ( AxiCfgAddrWidth ),
    .AxiDataWidth ( AxiCfgDataWidth ),
    .AxiIdWidth   ( AxiCfgIdWidth   ),
    .AxiUserWidth ( AxiCfgUserWidth ),
    .RegDataWidth ( 64              ),
    .axi_req_t    ( axi_cfg_req_t   ),
    .axi_rsp_t    ( axi_cfg_rsp_t   ),
    .reg_req_t    ( dma_reg_req_t   ),
    .reg_rsp_t    ( dma_reg_rsp_t   )
  ) i_cfg_axi_to_reg (
    .clk_i,
    .rst_ni,
    .axi_req_i  ( cfg_req_cut      ),
    .axi_rsp_o  ( cfg_rsp_cut      ),
    .reg_req_o  ( dma_reg_req_full ),
    .reg_rsp_i  ( dma_reg_rsp      ),
    .reg_id_o   ( /* unused */     ),
    .busy_o     ( /* unused */     )
  );

  // Strip the base address: the desc64 reg_wrapper compares the full
  // addr field against 4-bit offset constants.  We pass only the low
  // bits so the comparison hits correctly.
  always_comb begin
    dma_reg_req      = dma_reg_req_full;
    dma_reg_req.addr = {60'b0, dma_reg_req_full.addr[3:0]};
  end

  // --------------------------------------------------------------------
  // Frontend: idma_desc64_top
  // --------------------------------------------------------------------
  idma_req_t                     be_req;
  logic                          be_req_valid, be_req_ready;
  idma_rsp_t                     be_rsp;
  logic                          be_rsp_valid, be_rsp_ready;
  idma_pkg::idma_busy_t          be_busy;

  // Frontend's own AXI master port (for fetching descriptors from memory)
  dma_axi_req_t  fe_axi_req;
  dma_axi_resp_t fe_axi_rsp;

  idma_desc64_top #(
    .AddrWidth       ( AxiMstAddrWidth              ),
    .DataWidth       ( AxiMstDataWidth              ),
    .AxiIdWidth      ( DmaIntIdWidth                ),
    .idma_req_t      ( idma_req_t                   ),
    .idma_rsp_t      ( idma_rsp_t                   ),
    .axi_rsp_t       ( dma_axi_resp_t               ),
    .axi_req_t       ( dma_axi_req_t                ),
    .axi_ar_chan_t   ( dma_axi_ar_chan_t             ),
    .axi_r_chan_t    ( dma_axi_r_chan_t              ),
    .reg_rsp_t       ( dma_reg_rsp_t                ),
    .reg_req_t       ( dma_reg_req_t                ),
    .InputFifoDepth  ( InputFifoDepth               ),
    .PendingFifoDepth( PendingFifoDepth             ),
    .BackendDepth    ( NumAxInFlight + BufferDepth   ),
    .NSpeculation    ( NSpeculation                  )
  ) i_frontend (
    .clk_i,
    .rst_ni,
    .master_req_o    ( fe_axi_req      ),
    .master_rsp_i    ( fe_axi_rsp      ),
    .axi_ar_id_i     ( dma_id_t'('1)   ),
    .axi_aw_id_i     ( dma_id_t'('1)   ),
    .slave_req_i     ( dma_reg_req     ),
    .slave_rsp_o     ( dma_reg_rsp     ),
    .idma_req_o      ( be_req          ),
    .idma_req_valid_o( be_req_valid    ),
    .idma_req_ready_i( be_req_ready    ),
    .idma_rsp_i      ( be_rsp          ),
    .idma_rsp_valid_i( be_rsp_valid    ),
    .idma_rsp_ready_o( be_rsp_ready    ),
    .idma_busy_i     ( |be_busy        ),
    .irq_o           ( irq_o           )
  );

  // --------------------------------------------------------------------
  // Backend: idma_backend_rw_axi
  // --------------------------------------------------------------------
  dma_axi_req_t  axi_read_req,  axi_write_req;
  dma_axi_resp_t axi_read_rsp,  axi_write_rsp;

  idma_backend_rw_axi #(
    .DataWidth           ( AxiMstDataWidth       ),
    .AddrWidth           ( AxiMstAddrWidth       ),
    .UserWidth           ( AxiMstUserWidth       ),
    .AxiIdWidth          ( DmaIntIdWidth         ),
    .NumAxInFlight       ( NumAxInFlight         ),
    .BufferDepth         ( BufferDepth           ),
    .TFLenWidth          ( TFLenWidth            ),
    .MemSysDepth         ( MemSysDepth           ),
    .RAWCouplingAvail    ( 1'b1                  ),
    .MaskInvalidData     ( 1'b1                  ),
    .HardwareLegalizer   ( 1'b1                  ),
    .RejectZeroTransfers ( 1'b1                  ),
    .ErrorCap            ( idma_pkg::NO_ERROR_HANDLING ),
    .idma_req_t          ( idma_req_t            ),
    .idma_rsp_t          ( idma_rsp_t            ),
    .idma_eh_req_t       ( idma_pkg::idma_eh_req_t ),
    .idma_busy_t         ( idma_pkg::idma_busy_t ),
    .axi_req_t           ( dma_axi_req_t         ),
    .axi_rsp_t           ( dma_axi_resp_t        ),
    .read_meta_channel_t ( read_meta_channel_t   ),
    .write_meta_channel_t( write_meta_channel_t  )
  ) i_backend (
    .clk_i,
    .rst_ni,
    .testmode_i      ( 1'b0          ),
    .idma_req_i      ( be_req        ),
    .req_valid_i     ( be_req_valid  ),
    .req_ready_o     ( be_req_ready  ),
    .idma_rsp_o      ( be_rsp        ),
    .rsp_valid_o     ( be_rsp_valid  ),
    .rsp_ready_i     ( be_rsp_ready  ),
    .idma_eh_req_i   ( '0            ),
    .eh_req_valid_i  ( 1'b1          ),
    .eh_req_ready_o  (               ),
    .axi_read_req_o  ( axi_read_req  ),
    .axi_read_rsp_i  ( axi_read_rsp  ),
    .axi_write_req_o ( axi_write_req ),
    .axi_write_rsp_i ( axi_write_rsp ),
    .busy_o          ( be_busy       )
  );

  // --------------------------------------------------------------------
  // Join backend R/W into single AXI port
  // --------------------------------------------------------------------
  dma_axi_req_t  be_joined_req;
  dma_axi_resp_t be_joined_rsp;

  axi_rw_join #(
    .axi_req_t  ( dma_axi_req_t  ),
    .axi_resp_t ( dma_axi_resp_t )
  ) i_rw_join (
    .clk_i,
    .rst_ni,
    .slv_read_req_i   ( axi_read_req  ),
    .slv_read_resp_o  ( axi_read_rsp  ),
    .slv_write_req_i  ( axi_write_req ),
    .slv_write_resp_o ( axi_write_rsp ),
    .mst_req_o        ( be_joined_req ),
    .mst_resp_i       ( be_joined_rsp )
  );

  // --------------------------------------------------------------------
  // AXI Mux: merge frontend (desc fetch) + backend (data) -> single master
  // The mux prepends 1 ID bit: output ID width = DmaIntIdWidth + 1 = AxiMstIdWidth
  // --------------------------------------------------------------------
  mux_axi_req_t  mux_out_req;
  mux_axi_resp_t mux_out_rsp;

  axi_mux #(
    .SlvAxiIDWidth ( DmaIntIdWidth       ),
    .slv_aw_chan_t ( dma_axi_aw_chan_t   ),
    .mst_aw_chan_t ( mux_axi_aw_chan_t   ),
    .w_chan_t      ( dma_axi_w_chan_t     ),
    .slv_b_chan_t  ( dma_axi_b_chan_t     ),
    .mst_b_chan_t  ( mux_axi_b_chan_t     ),
    .slv_ar_chan_t ( dma_axi_ar_chan_t    ),
    .mst_ar_chan_t ( mux_axi_ar_chan_t    ),
    .slv_r_chan_t  ( dma_axi_r_chan_t     ),
    .mst_r_chan_t  ( mux_axi_r_chan_t     ),
    .slv_req_t     ( dma_axi_req_t       ),
    .slv_resp_t    ( dma_axi_resp_t      ),
    .mst_req_t     ( mux_axi_req_t       ),
    .mst_resp_t    ( mux_axi_resp_t      ),
    .NoSlvPorts    ( 2                   ),
    .MaxWTrans     ( NumAxInFlight       ),
    .FallThrough   ( 1'b0               ),
    .SpillAw       ( 1'b1               ),
    .SpillW        ( 1'b1               ),
    .SpillB        ( 1'b1               ),
    .SpillAr       ( 1'b1               ),
    .SpillR        ( 1'b1               )
  ) i_axi_mux (
    .clk_i,
    .rst_ni,
    .test_i      ( 1'b0                             ),
    .slv_reqs_i  ( {be_joined_req, fe_axi_req}      ),
    .slv_resps_o ( {be_joined_rsp, fe_axi_rsp}      ),
    .mst_req_o   ( mux_out_req                      ),
    .mst_resp_i  ( mux_out_rsp                      )
  );

  // Pass the mux output to the external master port
  assign mst_req_o   = mux_out_req;
  assign mux_out_rsp = mst_rsp_i;

endmodule
