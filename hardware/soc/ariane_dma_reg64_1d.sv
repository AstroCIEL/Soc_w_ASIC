// Copyright 2024 HUJIYONG. SPDX-License-Identifier: SHL-0.51
//
// dma_subsystem.sv
// ----------------
// A thin wrapper around the iDMA IP that exposes ONE AXI4 config slave and
// ONE AXI4 data master to the surrounding SoC.
//
// Topology (per user requirements):
//   cfg  (AXI4 slave, 64b)  ──► axi_to_reg_v2 ──► idma_reg64_1d (frontend)
//                                                    │
//                                                    ▼  idma_req_t
//                               idma_backend_rw_axi (no midend)
//                                    │            │
//                                    ▼            ▼
//                              axi_read_req   axi_write_req
//                                    └──► axi_rw_join ──► mst (AXI4 master)
//
// Notes
// * irq_o is a sticky "transfer-done" line, set on every backend response and
//   cleared by reading the DONE_ID register (see driver).
// * `axi_rw_join` keeps the ID width unchanged — the backend produces only
//   read or only write transactions on each slave port, so concatenating AR/R
//   from the read port with AW/W/B from the write port is collision-free.

`include "axi/typedef.svh"
`include "axi/assign.svh"
`include "register_interface/typedef.svh"
`include "idma/typedef.svh"

module ariane_dma_reg64_1d #(
  /// Configuration AXI slave port widths (matches SoC xbar master-port width).
  parameter int unsigned AxiCfgAddrWidth  = 64,
  parameter int unsigned AxiCfgDataWidth  = 64,
  parameter int unsigned AxiCfgIdWidth    = 4,
  parameter int unsigned AxiCfgUserWidth  = 1,
  /// Data-path AXI master port widths (drives SoC xbar slave port).
  parameter int unsigned AxiMstAddrWidth  = 64,
  parameter int unsigned AxiMstDataWidth  = 64,
  parameter int unsigned AxiMstIdWidth    = 4,  // external ID width
  parameter int unsigned AxiMstUserWidth  = 1,
  /// iDMA tunables (see iDMA docs).
  parameter int unsigned NumAxInFlight    = 3,
  parameter int unsigned BufferDepth      = 3,
  parameter int unsigned TFLenWidth       = 32,
  parameter int unsigned MemSysDepth      = 0,
  /// Slave / master struct types.  Callers pass the types they've locally
  /// typedef'd; the wrapper does not impose a particular naming convention.
  parameter type         axi_cfg_req_t    = logic,
  parameter type         axi_cfg_rsp_t    = logic,
  parameter type         axi_mst_req_t    = logic,
  parameter type         axi_mst_rsp_t    = logic
) (
  input  logic            clk_i,
  input  logic            rst_ni,

  /// Config slave (CPU ⇄ DMA registers)
  input  axi_cfg_req_t    cfg_req_i,
  output axi_cfg_rsp_t    cfg_rsp_o,

  /// Data master (DMA ⇄ memory)
  output axi_mst_req_t    mst_req_o,
  input  axi_mst_rsp_t    mst_rsp_i,

  /// Transfer-done interrupt (level, W1C via DONE_ID register)
  output logic            irq_o
);

  // --------------------------------------------------------------------
  // Internal widths / types
  // --------------------------------------------------------------------
  // Internal iDMA master ID width — must allow axi_mux (2 slv ports) to
  // prepend 1 bit and still fit inside AxiMstIdWidth.
  // axi_rw_join does not extend the ID, so the internal DMA ID width equals
  // the external master ID width.
  localparam int unsigned DmaIntIdWidth = AxiMstIdWidth;
  localparam int unsigned StrbWidth     = AxiMstDataWidth / 8;

  typedef logic [AxiMstAddrWidth-1:0] addr_t;
  typedef logic [AxiMstDataWidth-1:0] data_t;
  typedef logic [StrbWidth-1:0]       strb_t;
  typedef logic [AxiMstUserWidth-1:0] user_t;
  typedef logic [DmaIntIdWidth-1:0]   dma_id_t;
  typedef logic [TFLenWidth-1:0]      tf_len_t;

  // AXI4 channels / req-rsp at the DMA-internal ID width
  `AXI_TYPEDEF_ALL(dma_axi, addr_t, dma_id_t, data_t, strb_t, user_t)

  // iDMA request / response / busy
  `IDMA_TYPEDEF_FULL_REQ_T(idma_req_t, dma_id_t, addr_t, tf_len_t)
  `IDMA_TYPEDEF_FULL_RSP_T(idma_rsp_t, addr_t)

  // Backend meta-channel types (idma_backend_rw_axi expects these wrapper
  // structs so it can stay protocol-agnostic).
  typedef struct packed { dma_axi_ar_chan_t ar_chan; } axi_read_meta_t;
  typedef struct packed { axi_read_meta_t   axi;     } read_meta_channel_t;
  typedef struct packed { dma_axi_aw_chan_t aw_chan; } axi_write_meta_t;
  typedef struct packed { axi_write_meta_t  axi;     } write_meta_channel_t;

  // --------------------------------------------------------------------
  // AXI config slave  →  32b reg interface
  // --------------------------------------------------------------------
  `REG_BUS_TYPEDEF_ALL(dma_reg, logic[AxiCfgAddrWidth-1:0],
                                logic[31:0], logic[3:0])

  dma_reg_req_t dma_reg_req;
  dma_reg_rsp_t dma_reg_rsp;

  axi_to_reg_v2 #(
    .AxiAddrWidth ( AxiCfgAddrWidth ),
    .AxiDataWidth ( AxiCfgDataWidth ),
    .AxiIdWidth   ( AxiCfgIdWidth   ),
    .AxiUserWidth ( AxiCfgUserWidth ),
    .RegDataWidth ( 32              ),
    .axi_req_t    ( axi_cfg_req_t   ),
    .axi_rsp_t    ( axi_cfg_rsp_t   ),
    .reg_req_t    ( dma_reg_req_t   ),
    .reg_rsp_t    ( dma_reg_rsp_t   )
  ) i_cfg_axi_to_reg (
    .clk_i,
    .rst_ni,
    .axi_req_i  ( cfg_req_i   ),
    .axi_rsp_o  ( cfg_rsp_o   ),
    .reg_req_o  ( dma_reg_req ),
    .reg_rsp_i  ( dma_reg_rsp ),
    .reg_id_o   ( /* unused */),
    .busy_o     ( /* unused */)
  );

  // --------------------------------------------------------------------
  // Frontend : reg64_1d
  // --------------------------------------------------------------------
  idma_req_t                     be_req;
  logic                          be_req_valid, be_req_ready;
  idma_rsp_t                     be_rsp;
  logic                          be_rsp_valid, be_rsp_ready;
  idma_pkg::idma_busy_t          be_busy;

  // Transfer-id counter (issued on FE→BE handshake, retired on BE rsp).
  localparam int unsigned IdCounterWidth = 32;
  logic [IdCounterWidth-1:0] next_id, done_id;

  idma_transfer_id_gen #(
    .IdWidth ( IdCounterWidth )
  ) i_id_gen (
    .clk_i,
    .rst_ni,
    .issue_i     ( be_req_valid & be_req_ready ),
    .retire_i    ( be_rsp_valid & be_rsp_ready ),
    .next_o      ( next_id                     ),
    .completed_o ( done_id                     )
  );

  idma_reg64_1d #(
    .NumRegs        ( 1                ),
    .NumStreams     ( 1                ),
    .IdCounterWidth ( IdCounterWidth   ),
    .reg_req_t      ( dma_reg_req_t    ),
    .reg_rsp_t      ( dma_reg_rsp_t    ),
    .dma_req_t      ( idma_req_t       )
  ) i_frontend (
    .clk_i,
    .rst_ni,
    .dma_ctrl_req_i ( dma_reg_req   ),
    .dma_ctrl_rsp_o ( dma_reg_rsp   ),
    .dma_req_o      ( be_req        ),
    .req_valid_o    ( be_req_valid  ),
    .req_ready_i    ( be_req_ready  ),
    .next_id_i      ( next_id       ),
    .stream_idx_o   ( /* NC */      ),
    .done_id_i      ( done_id       ),
    .busy_i         ( be_busy       ),
    .midend_busy_i  ( 1'b0          )
  );

  // Frontend always accepts responses; we track completions ourselves via
  // the id generator.  Tie rsp_ready to 1 so the backend can retire freely.
  assign be_rsp_ready = 1'b1;

  // --------------------------------------------------------------------
  // Backend : rw_axi (no midend)
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
    .eh_req_valid_i  ( 1'b0          ),
    .eh_req_ready_o  (               ),
    .axi_read_req_o  ( axi_read_req  ),
    .axi_read_rsp_i  ( axi_read_rsp  ),
    .axi_write_req_o ( axi_write_req ),
    .axi_write_rsp_i ( axi_write_rsp ),
    .busy_o          ( be_busy       )
  );

  // --------------------------------------------------------------------
  // Join R/W masters into a single SoC-facing master via axi_rw_join.
  // No ID extension needed — the read port only drives AR/R and the write
  // port only drives AW/W/B.
  // --------------------------------------------------------------------
  dma_axi_req_t  join_mst_req;
  dma_axi_resp_t join_mst_rsp;

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
    .mst_req_o        ( join_mst_req  ),
    .mst_resp_i       ( join_mst_rsp  )
  );

  // Pass the joined req/resp pair up through the wrapper's opaque types.
  // The integrator is expected to supply identically-laid-out structs.
  assign mst_req_o    = join_mst_req;
  assign join_mst_rsp = mst_rsp_i;

  // --------------------------------------------------------------------
  // Sticky "done" IRQ
  //   * set on any backend response
  //   * cleared when SW reads the DONE_ID register (next_id==done_id)
  // --------------------------------------------------------------------
  logic irq_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      irq_q <= 1'b0;
    end else begin
      if (be_rsp_valid && be_rsp_ready)
        irq_q <= 1'b1;
      else if (done_id == next_id && !be_busy) // done_id <= next_id
        irq_q <= 1'b0;
    end
  end
  assign irq_o = irq_q;

endmodule
