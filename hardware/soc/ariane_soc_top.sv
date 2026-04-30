// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 19.03.2017
// Description: Test-harness for Ariane
//              Instantiates an AXI-Bus and memories

`include "axi/assign.svh"
`include "axi/typedef.svh"
`include "ara/intf_typedef.svh"
`include "rvfi_types.svh"


module ariane_soc_top import axi_pkg::*; import ara_pkg::*; #(
  // Ara-specific parameters
  parameter int unsigned NrLanes            = ariane_soc::NrLanes,
  parameter int unsigned VLEN               = ariane_soc::VLEN,
  //
  parameter config_pkg::cva6_cfg_t CVA6Cfg = build_config_pkg::build_config(cva6_config_pkg::cva6_cfg),
  //
  parameter int unsigned AXI_USER_WIDTH    = CVA6Cfg.AxiUserWidth,
  parameter int unsigned AXI_USER_EN       = CVA6Cfg.AXI_USER_EN,
  parameter int unsigned AXI_ADDRESS_WIDTH = 64,
  parameter int unsigned AXI_DATA_WIDTH    = 32*ariane_soc::NrLanes
) (
  input  logic                           clk_i,
  input  logic                           rtc_i,
  input  logic                           rst_ni,
  input  logic                           uart_rx_i,
  output logic                           uart_tx_o,
  output logic [31:0]                    exit_o,
  input  logic                           jtag_tck_i,
  input  logic                           jtag_tms_i,
  input  logic                           jtag_tdi_i,
  input  logic                           jtag_trst_ni,
  output logic                           jtag_tdo_o,
  output logic                           jtag_tdo_driven_o,
  input  logic                           debug_enable_i 
);

  localparam [7:0] hart_id = '0;

  localparam int unsigned NUM_WORDS = ariane_soc::DRAMLength / (AXI_DATA_WIDTH / 8);

  // ---------------
  // Ara AXI type definitions (matching ara_soc)
  // ---------------
  localparam AxiIdWidth        = ariane_axi::IdWidth;
  localparam AxiNarrowDataWidth = 64;
  localparam AxiWideDataWidth  = 64 * NrLanes / 2;
  localparam AxiSocIdWidth     = AxiIdWidth - $clog2(ariane_soc::NrSlaves);
  localparam AxiCoreIdWidth    = AxiIdWidth - 1;

  typedef logic [AxiNarrowDataWidth-1:0] axi_narrow_data_t;
  typedef logic [AxiNarrowDataWidth/8-1:0] axi_narrow_strb_t;
  typedef logic [AXI_ADDRESS_WIDTH-1:0] axi_addr_t;
  typedef logic [AXI_USER_WIDTH-1:0] axi_user_t;
  typedef logic [AxiWideDataWidth-1:0] axi_wide_data_t;
  typedef logic [AxiWideDataWidth/8-1:0] axi_wide_strb_t;
  typedef logic [AxiCoreIdWidth-1:0] axi_core_id_t;
  typedef logic [AxiIdWidth-1:0] axi_id_t;

  `AXI_TYPEDEF_ALL(system, axi_addr_t, axi_id_t, axi_wide_data_t, axi_wide_strb_t, axi_user_t)
  `AXI_TYPEDEF_ALL(ara_axi, axi_addr_t, axi_core_id_t, axi_wide_data_t, axi_wide_strb_t, axi_user_t)
  `AXI_TYPEDEF_ALL(ariane_axi_typed, axi_addr_t, axi_core_id_t, axi_narrow_data_t, axi_narrow_strb_t, axi_user_t)

  // Exception and accelerator interface types for ara_system
  `CVA6_TYPEDEF_EXCEPTION(exception_t, CVA6Cfg)
  `CVA6_INTF_TYPEDEF_ACC_REQ(accelerator_req_t, CVA6Cfg, fpnew_pkg::roundmode_e)
  `CVA6_INTF_TYPEDEF_ACC_RESP(accelerator_resp_t, CVA6Cfg, exception_t)
  `CVA6_INTF_TYPEDEF_MMU_REQ(acc_mmu_req_t, CVA6Cfg)
  `CVA6_INTF_TYPEDEF_MMU_RESP(acc_mmu_resp_t, CVA6Cfg, exception_t)
  `CVA6_INTF_TYPEDEF_CVA6_TO_ACC(cva6_to_acc_t, accelerator_req_t, acc_mmu_resp_t)
  `CVA6_INTF_TYPEDEF_ACC_TO_CVA6(acc_to_cva6_t, accelerator_resp_t, acc_mmu_req_t)

  // RVFI PROBES — must match the exact struct that cva6 drives internally
  localparam type rvfi_probes_instr_t = `RVFI_PROBES_INSTR_T(CVA6Cfg);
  localparam type rvfi_probes_csr_t   = `RVFI_PROBES_CSR_T(CVA6Cfg);
  localparam type rvfi_probes_t       = struct packed {
    rvfi_probes_csr_t   csr;
    rvfi_probes_instr_t instr;
  };

  // disable test-enable
  logic        test_en;
  logic        ndmreset;
  logic        ndmreset_n;
  logic        debug_req_core;

  logic        init_done;
  logic [31:0] rvfi_exit;
  logic [31:0] tracer_exit;
  logic [31:0] tandem_exit;

  logic        debug_req_valid;
  logic        debug_req_ready;
  logic        debug_resp_valid;
  logic        debug_resp_ready;

  logic        jtag_req_valid;
  logic [6:0]  jtag_req_bits_addr;
  logic [1:0]  jtag_req_bits_op;
  logic [31:0] jtag_req_bits_data;
  logic        jtag_resp_ready;
  logic        jtag_resp_valid;

  dm::dmi_req_t  jtag_dmi_req;

  dm::dmi_req_t  debug_req;
  dm::dmi_resp_t debug_resp;

  assign test_en = 1'b0;

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH       ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH          ),
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidth ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH          )
  ) slave[ariane_soc::NrSlaves-1:0]();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               )
  ) master[ariane_soc::NB_PERIPHERALS-1:0]();

  rstgen i_rstgen_main (
    .clk_i        ( clk_i                ),
    .rst_ni       ( rst_ni & (~ndmreset) ),
    .test_mode_i  ( test_en              ),
    .rst_no       ( ndmreset_n           ),
    .init_no      (                      ) // keep open
  );

  // ---------------
  // Debug
  // ---------------
  assign init_done = rst_ni;

  initial begin
    if (CVA6Cfg.XLEN != 32 & CVA6Cfg.XLEN != 64) $error("CVA6Cfg.XLEN different from 32 and 64");
  end

  // debug path: always use SimJTAG (SimDTM removed)
  assign debug_req_valid     = jtag_req_valid;
  assign debug_resp_ready    = jtag_resp_ready;
  assign debug_req           = jtag_dmi_req;
  assign jtag_resp_valid     = debug_resp_valid;

  dmi_jtag i_dmi_jtag (
    .clk_i            ( clk_i           ),
    .rst_ni           ( rst_ni          ),
    .testmode_i       ( test_en         ),
    .dmi_req_o        ( jtag_dmi_req    ),
    .dmi_req_valid_o  ( jtag_req_valid  ),
    .dmi_req_ready_i  ( debug_req_ready ),
    .dmi_resp_i       ( debug_resp      ),
    .dmi_resp_ready_o ( jtag_resp_ready ),
    .dmi_resp_valid_i ( jtag_resp_valid ),
    .dmi_rst_no       (                 ), // not connected
    .tck_i            ( jtag_tck_i      ),
    .tms_i            ( jtag_tms_i      ),
    .trst_ni          ( jtag_trst_ni    ),
    .td_i             ( jtag_tdi_i      ),
    .td_o             ( jtag_tdo_o      ),
    .tdo_oe_o         ( jtag_tdo_driven_o )
  );


  // this delay window allows the core to read and execute init code
  // from the bootrom before the first debug request can interrupt
  // core. this is needed in cases where an fsbl is involved that
  // expects a0 and a1 to be initialized with the hart id and a
  // pointer to the dev tree, respectively.
  localparam int unsigned DmiDelCycles = 500;

  logic debug_req_core_ungtd;
  int dmi_del_cnt_d, dmi_del_cnt_q;

  assign dmi_del_cnt_d  = (dmi_del_cnt_q) ? dmi_del_cnt_q - 1 : 0;
  assign debug_req_core = (dmi_del_cnt_q) ? 1'b0 :
                          (!debug_enable_i) ? 1'b0 : debug_req_core_ungtd;

  always_ff @(posedge clk_i or negedge rst_ni) begin : p_dmi_del_cnt
    if(!rst_ni) begin
      dmi_del_cnt_q <= DmiDelCycles;
    end else begin
      dmi_del_cnt_q <= dmi_del_cnt_d;
    end
  end

  ariane_axi::req_t    dm_axi_m_req;
  ariane_axi::resp_t   dm_axi_m_resp;

  logic                dm_slave_req;
  logic                dm_slave_we;
  logic [64-1:0]       dm_slave_addr;
  logic [64/8-1:0]     dm_slave_be;
  logic [64-1:0]       dm_slave_wdata;
  logic [64-1:0]       dm_slave_rdata;

  logic                dm_master_req;
  logic [64-1:0]       dm_master_add;
  logic                dm_master_we;
  logic [64-1:0]       dm_master_wdata;
  logic [64/8-1:0]     dm_master_be;
  logic                dm_master_gnt;
  logic                dm_master_r_valid;
  logic [64-1:0]       dm_master_r_rdata;

  // debug module
  dm_top #(
    .NrHarts              ( 1                           ),
    .BusWidth             ( AXI_DATA_WIDTH              ),
    .SelectableHarts      ( 1'b1                        )
  ) i_dm_top (
    .clk_i                ( clk_i                       ),
    .rst_ni               ( rst_ni                      ), // PoR
    .testmode_i           ( test_en                     ),
    .ndmreset_o           ( ndmreset                    ),
    .dmactive_o           (                             ), // active debug session
    .debug_req_o          ( debug_req_core_ungtd        ),
    .unavailable_i        ( '0                          ),
    .hartinfo_i           ( {ariane_pkg::DebugHartInfo} ),
    .slave_req_i          ( dm_slave_req                ),
    .slave_we_i           ( dm_slave_we                 ),
    .slave_addr_i         ( dm_slave_addr               ),
    .slave_be_i           ( dm_slave_be                 ),
    .slave_wdata_i        ( dm_slave_wdata              ),
    .slave_rdata_o        ( dm_slave_rdata              ),
    .master_req_o         ( dm_master_req               ),
    .master_add_o         ( dm_master_add               ),
    .master_we_o          ( dm_master_we                ),
    .master_wdata_o       ( dm_master_wdata             ),
    .master_be_o          ( dm_master_be                ),
    .master_gnt_i         ( dm_master_gnt               ),
    .master_r_valid_i     ( dm_master_r_valid           ),
    .master_r_rdata_i     ( dm_master_r_rdata           ),
    .dmi_rst_ni           ( rst_ni                      ),
    .dmi_req_valid_i      ( debug_req_valid             ),
    .dmi_req_ready_o      ( debug_req_ready             ),
    .dmi_req_i            ( debug_req                   ),
    .dmi_resp_valid_o     ( debug_resp_valid            ),
    .dmi_resp_ready_i     ( debug_resp_ready            ),
    .dmi_resp_o           ( debug_resp                  )
  );


  axi2mem #(
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               )
  ) i_dm_axi2mem (
    .clk_i      ( clk_i                     ),
    .rst_ni     ( rst_ni                    ),
    .slave      ( master[ariane_soc::Debug] ),
    .req_o      ( dm_slave_req              ),
    .we_o       ( dm_slave_we               ),
    .addr_o     ( dm_slave_addr             ),
    .be_o       ( dm_slave_be               ),
    .user_o     (                           ),
    .data_o     ( dm_slave_wdata            ),
    .user_i     ( '0                        ),
    .data_i     ( dm_slave_rdata            )
  );

  `AXI_ASSIGN_FROM_REQ(slave[1], dm_axi_m_req)
  `AXI_ASSIGN_TO_RESP(dm_axi_m_resp, slave[1])

  axi_adapter #(
    .CVA6Cfg               ( CVA6Cfg                   ),
    .DATA_WIDTH            ( AXI_DATA_WIDTH            ),
    .axi_req_t             ( ariane_axi::req_t         ),
    .axi_rsp_t             ( ariane_axi::resp_t        )
  ) i_dm_axi_master (
    .clk_i                 ( clk_i                     ),
    .rst_ni                ( rst_ni                    ),
    .req_i                 ( dm_master_req             ),
    .type_i                ( ariane_pkg::SINGLE_REQ    ),
    .amo_i                 ( ariane_pkg::AMO_NONE      ),
    .gnt_o                 ( dm_master_gnt             ),
    .addr_i                ( dm_master_add             ),
    .we_i                  ( dm_master_we              ),
    .wdata_i               ( dm_master_wdata           ),
    .be_i                  ( dm_master_be              ),
    .size_i                ( 2'b11                     ), // always do 64bit here and use byte enables to gate
    .id_i                  ( '0                        ),
    .valid_o               ( dm_master_r_valid         ),
    .rdata_o               ( dm_master_r_rdata         ),
    .id_o                  (                           ),
    .critical_word_o       (                           ),
    .critical_word_valid_o (                           ),
    .axi_req_o             ( dm_axi_m_req              ),
    .axi_resp_i            ( dm_axi_m_resp             )
  );


  // ---------------
  // ROM
  // ---------------
  logic                         rom_req;
  logic [AXI_ADDRESS_WIDTH-1:0] rom_addr;
  logic [AXI_DATA_WIDTH-1:0]    rom_rdata;

  axi2mem #(
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               )
  ) i_axi2rom (
    .clk_i  ( clk_i                   ),
    .rst_ni ( ndmreset_n              ),
    .slave  ( master[ariane_soc::ROM] ),
    .req_o  ( rom_req                 ),
    .we_o   (                         ),
    .addr_o ( rom_addr                ),
    .be_o   (                         ),
    .user_o (                         ),
    .data_o (                         ),
    .user_i ( '0                      ),
    .data_i ( rom_rdata               )
  );

  bootrom i_bootrom (
    .clk_i      ( clk_i     ),
    .req_i      ( rom_req   ),
    .addr_i     ( rom_addr  ),
    .rdata_o    ( rom_rdata )
  );

  // ------------------------------
  // GPIO
  // ------------------------------

  // GPIO not implemented, adding an error slave here

  ariane_axi_soc::req_slv_t  gpio_req;
  ariane_axi_soc::resp_slv_t gpio_resp;
  `AXI_ASSIGN_TO_REQ(gpio_req, master[ariane_soc::GPIO])
  `AXI_ASSIGN_FROM_RESP(master[ariane_soc::GPIO], gpio_resp)
  axi_err_slv #(
    .AxiIdWidth  ( ariane_axi_soc::IdWidthSlave ),
    .axi_req_t   ( ariane_axi_soc::req_slv_t    ),
    .axi_resp_t  ( ariane_axi_soc::resp_slv_t   )
  ) i_gpio_err_slv (
    .clk_i      ( clk_i      ),
    .rst_ni     ( ndmreset_n ),
    .test_i     ( test_en    ),
    .slv_req_i  ( gpio_req ),
    .slv_resp_o ( gpio_resp )
  );


  // ------------------------------
  // Memory + Exclusive Access
  // ------------------------------
  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               )
  ) dram();

  logic                         req;
  logic                         we;
  logic [AXI_ADDRESS_WIDTH-1:0] addr;
  logic [AXI_DATA_WIDTH/8-1:0]  be;
  logic [AXI_DATA_WIDTH-1:0]    wdata;
  logic [AXI_DATA_WIDTH-1:0]    rdata;
  logic [AXI_USER_WIDTH-1:0]    wuser;
  logic [AXI_USER_WIDTH-1:0]    ruser;

  axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               ),
    .AXI_MAX_READ_TXNS  ( 4  ),
    .AXI_MAX_WRITE_TXNS ( 4  ),
    .RISCV_WORD_WIDTH   ( 64 )
  ) i_axi_riscv_atomics (
    .clk_i,
    .rst_ni ( ndmreset_n               ),
    .slv    ( master[ariane_soc::DRAM] ),
    .mst    ( dram                     )
  );

  axi2mem #(
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               )
  ) i_axi2mem (
    .clk_i  ( clk_i   ),
    .rst_ni ( ndmreset_n ),
    .slave  ( dram    ),
    .req_o  ( req          ),
    .we_o   ( we           ),
    .addr_o ( addr         ),
    .be_o   ( be           ),
    .user_o ( wuser        ),
    .data_o ( wdata        ),
    .user_i ( ruser        ),
    .data_i ( rdata        )
  );

  paired_sram_wrapper #(
    .DATA_WIDTH ( AXI_DATA_WIDTH ),
    .USER_WIDTH ( AXI_USER_WIDTH ),
    .USER_EN    ( AXI_USER_EN    ),
    .SIM_INIT   ( "zeros"         ),
    .NUM_WORDS  ( NUM_WORDS      )
  ) i_sram (
    .clk_i      ( clk_i                                                                       ),
    .rst_ni     ( rst_ni                                                                      ),
    .req_i      ( req                                                                         ),
    .we_i       ( we                                                                          ),
    .addr_i     ( addr[$clog2(NUM_WORDS)-1+$clog2(AXI_DATA_WIDTH/8):$clog2(AXI_DATA_WIDTH/8)] ),
    .wuser_i    ( wuser                                                                       ),
    .wdata_i    ( wdata                                                                       ),
    .be_i       ( be                                                                          ),
    .ruser_o    ( ruser                                                                       ),
    .rdata_o    ( rdata                                                                       )
  );

  // ---------------
  // AXI Xbar
  // ---------------

  axi_pkg::xbar_rule_64_t [ariane_soc::NB_PERIPHERALS-1:0] addr_map;

  assign addr_map = '{
    '{ idx: ariane_soc::Debug,    start_addr: ariane_soc::DebugBase,    end_addr: ariane_soc::DebugBase + ariane_soc::DebugLength       },
    '{ idx: ariane_soc::ROM,      start_addr: ariane_soc::ROMBase,      end_addr: ariane_soc::ROMBase + ariane_soc::ROMLength           },
    '{ idx: ariane_soc::CLINT,    start_addr: ariane_soc::CLINTBase,    end_addr: ariane_soc::CLINTBase + ariane_soc::CLINTLength       },
    '{ idx: ariane_soc::PLIC,     start_addr: ariane_soc::PLICBase,     end_addr: ariane_soc::PLICBase + ariane_soc::PLICLength         },
    '{ idx: ariane_soc::UART,     start_addr: ariane_soc::UARTBase,     end_addr: ariane_soc::UARTBase + ariane_soc::UARTLength         },
    '{ idx: ariane_soc::Timer,    start_addr: ariane_soc::TimerBase,    end_addr: ariane_soc::TimerBase + ariane_soc::TimerLength       },
    '{ idx: ariane_soc::GPIO,     start_addr: ariane_soc::GPIOBase,     end_addr: ariane_soc::GPIOBase + ariane_soc::GPIOLength         },
    '{ idx: ariane_soc::DRAM,     start_addr: ariane_soc::DRAMBase,     end_addr: ariane_soc::DRAMBase + ariane_soc::DRAMLength         },
    '{ idx: ariane_soc::Ctrl,     start_addr: ariane_soc::CtrlBase,     end_addr: ariane_soc::CtrlBase + ariane_soc::CtrlLength         },
    '{ idx: ariane_soc::DefaultSlave, start_addr: ariane_soc::DefaultSlaveBase, end_addr: ariane_soc::DefaultSlaveBase + ariane_soc::DefaultSlaveLength }
  };

  localparam axi_pkg::xbar_cfg_t AXI_XBAR_CFG = '{
    NoSlvPorts: unsigned'(ariane_soc::NrSlaves),
    NoMstPorts: unsigned'(ariane_soc::NB_PERIPHERALS),
    MaxMstTrans: unsigned'(1), // Probably requires update
    MaxSlvTrans: unsigned'(1), // Probably requires update
    FallThrough: 1'b0,
    LatencyMode: axi_pkg::NO_LATENCY,
    PipelineStages: 0,
    AxiIdWidthSlvPorts: unsigned'(ariane_axi_soc::IdWidth),
    AxiIdUsedSlvPorts: unsigned'(ariane_axi_soc::IdWidth),
    UniqueIds: 1'b0,
    AxiAddrWidth: unsigned'(AXI_ADDRESS_WIDTH),
    AxiDataWidth: unsigned'(AXI_DATA_WIDTH),
    NoAddrRules: unsigned'(ariane_soc::NB_PERIPHERALS)
  };

  axi_xbar_intf #(
    .AXI_USER_WIDTH ( AXI_USER_WIDTH          ),
    .Cfg            ( AXI_XBAR_CFG            ),
    .rule_t         ( axi_pkg::xbar_rule_64_t )
  ) i_axi_xbar (
    .clk_i                 ( clk_i      ),
    .rst_ni                ( ndmreset_n ),
    .test_i                ( test_en    ),
    .slv_ports             ( slave      ),
    .mst_ports             ( master     ),
    .addr_map_i            ( addr_map   ),
    .en_default_mst_port_i ( '0         ),
    .default_mst_port_i    ( '0         )
  );

  // ---------------
  // CLINT
  // ---------------
  logic ipi;
  logic timer_irq;

  ariane_axi_soc::req_slv_t  axi_clint_req;
  ariane_axi_soc::resp_slv_t axi_clint_resp;

  clint #(
    .CVA6Cfg        ( CVA6Cfg                      ),
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .NR_CORES       ( 1                            ),
    .axi_req_t      ( ariane_axi_soc::req_slv_t    ),
    .axi_resp_t     ( ariane_axi_soc::resp_slv_t   )
  ) i_clint (
    .clk_i       ( clk_i          ),
    .rst_ni      ( ndmreset_n     ),
    .testmode_i  ( test_en        ),
    .axi_req_i   ( axi_clint_req  ),
    .axi_resp_o  ( axi_clint_resp ),
    .rtc_i       ( rtc_i          ),
    .timer_irq_o ( timer_irq      ),
    .ipi_o       ( ipi            )
  );

  `AXI_ASSIGN_TO_REQ(axi_clint_req, master[ariane_soc::CLINT])
  `AXI_ASSIGN_FROM_RESP(master[ariane_soc::CLINT], axi_clint_resp)

  // ---------------
  // Peripherals
  // ---------------
  logic [1:0] irqs;

  logic [AXI_DATA_WIDTH-1:0] ctrl_exit;
  logic [AXI_DATA_WIDTH-1:0] ctrl_event_trigger;
  logic [AXI_DATA_WIDTH-1:0] ctrl_hw_cnt_en;

  ariane_peripherals #(
    .AxiAddrWidth ( AXI_ADDRESS_WIDTH            ),
    .AxiDataWidth ( AXI_DATA_WIDTH               ),
    .AxiIdWidth   ( ariane_axi_soc::IdWidthSlave ),
    .AxiUserWidth ( AXI_USER_WIDTH               ),
    .DRAMBase     ( ariane_soc::DRAMBase         ),
    .DRAMLength   ( ariane_soc::DRAMLength       )
  ) i_ariane_peripherals (
    .clk_i          ( clk_i                        ),
    .rst_ni         ( ndmreset_n                   ),
    .plic           ( master[ariane_soc::PLIC]     ),
    .uart           ( master[ariane_soc::UART]     ),
    .timer          ( master[ariane_soc::Timer]    ),
    .ctrl           ( master[ariane_soc::Ctrl]     ),
    .default_slave  ( master[ariane_soc::DefaultSlave] ),
    .irq_o          ( irqs                         ),
    .exit_o         ( ctrl_exit                    ),
    .event_trigger_o( ctrl_event_trigger           ),
    .hw_cnt_en_o    ( ctrl_hw_cnt_en               ),
    .rx_i           ( uart_rx_i                    ),
    .tx_o           ( uart_tx_o                    )
  );

  assign exit_o = {31'b0, ctrl_exit[0]};
  

  // ---------------
  // Core (ara_system replacing ariane)
  // ---------------
  system_req_t   axi_system_req;
  system_resp_t  axi_system_resp;
  rvfi_probes_t  rvfi_probes;

  ara_system #(
    .NrLanes            ( NrLanes                   ),
    .VLEN               ( VLEN                      ),
    .CVA6Cfg            ( CVA6Cfg                   ),
    .exception_t        ( exception_t               ),
    .accelerator_req_t  ( accelerator_req_t         ),
    .accelerator_resp_t ( accelerator_resp_t        ),
    .acc_mmu_req_t      ( acc_mmu_req_t             ),
    .acc_mmu_resp_t     ( acc_mmu_resp_t            ),
    .cva6_to_acc_t      ( cva6_to_acc_t             ),
    .acc_to_cva6_t      ( acc_to_cva6_t             ),
    .rvfi_probes_instr_t( rvfi_probes_instr_t       ),
    .rvfi_probes_csr_t  ( rvfi_probes_csr_t         ),
    .rvfi_probes_t      ( rvfi_probes_t             ),
    .AxiAddrWidth       ( AXI_ADDRESS_WIDTH         ),
    .AxiIdWidth         ( AxiCoreIdWidth            ),
    .AxiNarrowDataWidth ( AxiNarrowDataWidth        ),
    .AxiWideDataWidth   ( AxiWideDataWidth          ),
    .ariane_axi_ar_t    ( ariane_axi_typed_ar_chan_t),
    .ariane_axi_aw_t    ( ariane_axi_typed_aw_chan_t),
    .ariane_axi_b_t     ( ariane_axi_typed_b_chan_t ),
    .ariane_axi_r_t     ( ariane_axi_typed_r_chan_t ),
    .ariane_axi_w_t     ( ariane_axi_typed_w_chan_t ),
    .ariane_axi_req_t   ( ariane_axi_typed_req_t    ),
    .ariane_axi_resp_t  ( ariane_axi_typed_resp_t   ),
    .ara_axi_ar_t       ( ara_axi_ar_chan_t         ),
    .ara_axi_aw_t       ( ara_axi_aw_chan_t         ),
    .ara_axi_b_t        ( ara_axi_b_chan_t          ),
    .ara_axi_r_t        ( ara_axi_r_chan_t          ),
    .ara_axi_w_t        ( ara_axi_w_chan_t          ),
    .ara_axi_req_t      ( ara_axi_req_t             ),
    .ara_axi_resp_t     ( ara_axi_resp_t            ),
    .system_axi_ar_t    ( system_ar_chan_t           ),
    .system_axi_aw_t    ( system_aw_chan_t           ),
    .system_axi_b_t     ( system_b_chan_t            ),
    .system_axi_r_t     ( system_r_chan_t            ),
    .system_axi_w_t     ( system_w_chan_t            ),
    .system_axi_req_t   ( system_req_t              ),
    .system_axi_resp_t  ( system_resp_t             )
  ) i_ara_system (
    .clk_i              ( clk_i               ),
    .rst_ni             ( ndmreset_n          ),
    .boot_addr_i        ( ariane_soc::ROMBase ), // start fetching from ROM
    .hart_id_i          ( hart_id[2:0]        ),
    .scan_enable_i      ( 1'b0                ),
    .scan_data_i        ( 1'b0                ),
    .scan_data_o        ( /* Unused */        ),
    .irq_i              ( irqs                ),
    .ipi_i              ( ipi                 ),
    .time_irq_i         ( timer_irq           ),
    .debug_req_i        ( debug_req_core      ),
    .rvfi_probes_o      ( rvfi_probes         ),
    .axi_req_o          ( axi_system_req      ),
    .axi_resp_i         ( axi_system_resp     )
  );

  `AXI_ASSIGN_FROM_REQ(slave[0], axi_system_req)
  `AXI_ASSIGN_TO_RESP(axi_system_resp, slave[0])

  // -------------
  // Simulation Helper Functions
  // -------------
  // check for response errors
  always_ff @(posedge clk_i) begin : p_assert
    if (axi_system_req.r_ready &&
      axi_system_resp.r_valid &&
      axi_system_resp.r.resp inside {axi_pkg::RESP_DECERR, axi_pkg::RESP_SLVERR}) begin
      $warning("R Response Errored");
    end
    if (axi_system_req.b_ready &&
      axi_system_resp.b_valid &&
      axi_system_resp.b.resp inside {axi_pkg::RESP_DECERR, axi_pkg::RESP_SLVERR}) begin
      $warning("B Response Errored");
    end
  end

  // RVFI tracer and related blocks are commented out for ara_system pre-test
  // (rvfi_tracer, cva6_rvfi, cva6_iti, rv_tracer, encapsulator, slicer, spike)
  assign rvfi_exit = '0;
  assign tracer_exit = '0;


`ifdef AXI_SVA
  // AXI 4 Assertion IP integration - You will need to get your own copy of this IP if you want
  // to use it
  Axi4PC #(
    .DATA_WIDTH(ariane_axi_soc::DataWidth),
    .WID_WIDTH(ariane_axi_soc::IdWidthSlave),
    .RID_WIDTH(ariane_axi_soc::IdWidthSlave),
    .AWUSER_WIDTH(ariane_axi_soc::UserWidth),
    .WUSER_WIDTH(ariane_axi_soc::UserWidth),
    .BUSER_WIDTH(ariane_axi_soc::UserWidth),
    .ARUSER_WIDTH(ariane_axi_soc::UserWidth),
    .RUSER_WIDTH(ariane_axi_soc::UserWidth),
    .ADDR_WIDTH(ariane_axi_soc::AddrWidth)
  ) i_Axi4PC (
    .ACLK(clk_i),
    .ARESETn(ndmreset_n),
    .AWID(dram.aw_id),
    .AWADDR(dram.aw_addr),
    .AWLEN(dram.aw_len),
    .AWSIZE(dram.aw_size),
    .AWBURST(dram.aw_burst),
    .AWLOCK(dram.aw_lock),
    .AWCACHE(dram.aw_cache),
    .AWPROT(dram.aw_prot),
    .AWQOS(dram.aw_qos),
    .AWREGION(dram.aw_region),
    .AWUSER(dram.aw_user),
    .AWVALID(dram.aw_valid),
    .AWREADY(dram.aw_ready),
    .WLAST(dram.w_last),
    .WDATA(dram.w_data),
    .WSTRB(dram.w_strb),
    .WUSER(dram.w_user),
    .WVALID(dram.w_valid),
    .WREADY(dram.w_ready),
    .BID(dram.b_id),
    .BRESP(dram.b_resp),
    .BUSER(dram.b_user),
    .BVALID(dram.b_valid),
    .BREADY(dram.b_ready),
    .ARID(dram.ar_id),
    .ARADDR(dram.ar_addr),
    .ARLEN(dram.ar_len),
    .ARSIZE(dram.ar_size),
    .ARBURST(dram.ar_burst),
    .ARLOCK(dram.ar_lock),
    .ARCACHE(dram.ar_cache),
    .ARPROT(dram.ar_prot),
    .ARQOS(dram.ar_qos),
    .ARREGION(dram.ar_region),
    .ARUSER(dram.ar_user),
    .ARVALID(dram.ar_valid),
    .ARREADY(dram.ar_ready),
    .RID(dram.r_id),
    .RLAST(dram.r_last),
    .RDATA(dram.r_data),
    .RRESP(dram.r_resp),
    .RUSER(dram.r_user),
    .RVALID(dram.r_valid),
    .RREADY(dram.r_ready),
    .CACTIVE('0),
    .CSYSREQ('0),
    .CSYSACK('0)
  );
`endif
endmodule
