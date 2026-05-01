// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Description:
// Minimal system — CVA6 scalar core only (no Ara VPU).
// CVA6's AXI output is connected directly to the system port.

module ara_system import axi_pkg::*; #(
    // Ariane configuration
    parameter config_pkg::cva6_cfg_t            CVA6Cfg            = cva6_config_pkg::cva6_cfg,
    // CVA6-related parameters
    parameter type                              exception_t        = logic,
    parameter type                              accelerator_req_t  = logic,
    parameter type                              accelerator_resp_t = logic,
    parameter type                              acc_mmu_req_t      = logic,
    parameter type                              acc_mmu_resp_t     = logic,
    parameter type                              cva6_to_acc_t      = logic,
    parameter type                              acc_to_cva6_t      = logic,
    // RVFI probe types
    parameter type                              rvfi_probes_instr_t = logic,
    parameter type                              rvfi_probes_csr_t   = logic,
    parameter type                              rvfi_probes_t       = logic,
    // AXI Interface
    parameter int                      unsigned AxiAddrWidth       = 64,
    parameter int                      unsigned AxiIdWidth         = 4,
    parameter int                      unsigned AxiDataWidth       = 64,
    parameter type                              axi_ar_t           = logic,
    parameter type                              axi_r_t            = logic,
    parameter type                              axi_aw_t           = logic,
    parameter type                              axi_w_t            = logic,
    parameter type                              axi_b_t            = logic,
    parameter type                              axi_req_t          = logic,
    parameter type                              axi_resp_t         = logic
  ) (
    input  logic                    clk_i,
    input  logic                    rst_ni,
    input  logic             [63:0] boot_addr_i,
    input                     [2:0] hart_id_i,
    // Scan chain
    input  logic                    scan_enable_i,
    input  logic                    scan_data_i,
    output logic                    scan_data_o,
    // Interrupt and debug ports
    input  logic              [1:0] irq_i,
    input  logic                    ipi_i,
    input  logic                    time_irq_i,
    input  logic                    debug_req_i,
    // RVFI probes output
    output rvfi_probes_t            rvfi_probes_o,
    // AXI Interface
    output axi_req_t                axi_req_o,
    input  axi_resp_t               axi_resp_i
  );

  // Scan data passthrough (no scan chain logic here)
  assign scan_data_o = scan_data_i;

  // Support max 8 cores
  logic [63:0] hart_id;
  assign hart_id = {'0, hart_id_i};

  // Accelerator interface — tied off (no Ara)
  cva6_to_acc_t  acc_req;
  acc_to_cva6_t  acc_resp_pack;
  assign acc_resp_pack = '0;

  cva6 #(
    .CVA6Cfg           (CVA6Cfg           ),
    .cvxif_req_t       (cva6_to_acc_t     ),
    .cvxif_resp_t      (acc_to_cva6_t     ),
    .axi_ar_chan_t     (axi_ar_t          ),
    .axi_aw_chan_t     (axi_aw_t          ),
    .axi_w_chan_t      (axi_w_t           ),
    .b_chan_t          (axi_b_t           ),
    .r_chan_t          (axi_r_t           ),
    .noc_req_t         (axi_req_t         ),
    .noc_resp_t        (axi_resp_t        ),
    .accelerator_req_t (accelerator_req_t ),
    .accelerator_resp_t(accelerator_resp_t),
    .acc_mmu_req_t     (acc_mmu_req_t     ),
    .acc_mmu_resp_t    (acc_mmu_resp_t    )
  ) i_cva6 (
    .clk_i            (clk_i                   ),
    .rst_ni           (rst_ni                  ),
    .boot_addr_i      (boot_addr_i             ),
    .hart_id_i        (hart_id                 ),
    .irq_i            (irq_i                   ),
    .ipi_i            (ipi_i                   ),
    .time_irq_i       (time_irq_i              ),
    .debug_req_i      (debug_req_i             ),
    .clic_irq_valid_i ('0                      ),
    .clic_irq_id_i    ('0                      ),
    .clic_irq_level_i ('0                      ),
    .clic_irq_priv_i  (riscv::priv_lvl_t'(2'b0)),
    .clic_irq_shv_i   ('0                      ),
    .clic_irq_ready_o (/* unused */            ),
    .clic_kill_req_i  ('0                      ),
    .clic_kill_ack_o  (/* unused */            ),
    .rvfi_probes_o    (rvfi_probes_o           ),
    // Accelerator ports — tied off
    .cvxif_req_o      (acc_req                 ),
    .cvxif_resp_i     (acc_resp_pack           ),
    // AXI output — directly to system port
    .noc_req_o        (axi_req_o               ),
    .noc_resp_i       (axi_resp_i              )
  );

endmodule : ara_system
