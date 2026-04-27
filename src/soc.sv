// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Description: Xilinx FPGA top-level
// Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

`include "axi_typedef.svh"
`include "axi_assign.svh"
`include "reg_typedef.svh"
`include "reg_assign.svh"

module soc (
`ifdef SIM
  // Virtual CLK
  input  logic        clk           ,
  // DCO Regs
  output logic [5:0] dco_cc_sel_o   ,
  output logic [5:0] dco_fc_sel_o   ,
  output logic [1:0] dco_freq_sel_o ,
  output logic [2:0] dco_div_sel_o  ,
`endif

  input  logic        rst_n       ,
  output logic        clk_led     ,
  input  logic        tck         ,
  input  logic        tms         ,
  input  logic        tdi         ,
  output logic        tdo         ,

// DCO Control
    input logic ext_clk             ,
    input logic dco_en              ,
    input logic clk_sel             ,
    input logic div_rst_n             

);

`ifndef SIM
// on-chip clk
logic clk;
`endif

// CVA6 config
localparam bit IsRVFI = bit'(0);
localparam config_pkg::cva6_cfg_t CVA6Cfg = '{
  NrCommitPorts:         cva6_config_pkg::CVA6ConfigNrCommitPorts,
  AxiAddrWidth:          cva6_config_pkg::CVA6ConfigAxiAddrWidth,
  AxiDataWidth:          cva6_config_pkg::CVA6ConfigAxiDataWidth,
  AxiIdWidth:            cva6_config_pkg::CVA6ConfigAxiIdWidth,
  AxiUserWidth:          cva6_config_pkg::CVA6ConfigDataUserWidth,
  NrLoadBufEntries:      cva6_config_pkg::CVA6ConfigNrLoadBufEntries,
  RASDepth:              cva6_config_pkg::CVA6ConfigRASDepth,
  BTBEntries:            cva6_config_pkg::CVA6ConfigBTBEntries,
  BHTEntries:            cva6_config_pkg::CVA6ConfigBHTEntries,
  FpuEn:                 bit'(cva6_config_pkg::CVA6ConfigFpuEn),
  XF16:                  bit'(cva6_config_pkg::CVA6ConfigF16En),
  XF16ALT:               bit'(cva6_config_pkg::CVA6ConfigF16AltEn),
  XF8:                   bit'(cva6_config_pkg::CVA6ConfigF8En),
  RVA:                   bit'(cva6_config_pkg::CVA6ConfigAExtEn),
  RVV:                   bit'(cva6_config_pkg::CVA6ConfigVExtEn),
  RVC:                   bit'(cva6_config_pkg::CVA6ConfigCExtEn),
  RVZCB:                 bit'(cva6_config_pkg::CVA6ConfigZcbExtEn),
  XFVec:                 bit'(cva6_config_pkg::CVA6ConfigFVecEn),
  CvxifEn:               bit'(cva6_config_pkg::CVA6ConfigCvxifEn),
  ZiCondExtEn:           bit'(0),
  RVF:                   bit'(0),
  RVD:                   bit'(0),
  FpPresent:             bit'(0),
  NSX:                   bit'(0),
  FLen:                  unsigned'(0),
  RVFVec:                bit'(0),
  XF16Vec:               bit'(0),
  XF16ALTVec:            bit'(0),
  XF8Vec:                bit'(0),
  NrRgprPorts:           unsigned'(0),
  NrWbPorts:             unsigned'(0),
  EnableAccelerator:     bit'(0),
  RVS:                   bit'(1),
  RVU:                   bit'(1),
  HaltAddress:           dm::HaltAddress,
  ExceptionAddress:      dm::ExceptionAddress,
  DmBaseAddress:         soc_pkg::DebugBase,
  NrPMPEntries:          unsigned'(cva6_config_pkg::CVA6ConfigNrPMPEntries),
  NOCType:               config_pkg::NOC_TYPE_AXI4_ATOP,
  // idempotent region
  NrNonIdempotentRules:  unsigned'(1),
  NonIdempotentAddrBase: 1024'({64'b0}),
  NonIdempotentLength:   1024'({64'b0}),
  NrExecuteRegionRules:  unsigned'(3),
  ExecuteRegionAddrBase: 1024'({soc_pkg::SRAMBase,   soc_pkg::ROMBase,   soc_pkg::DebugBase}),
  ExecuteRegionLength:   1024'({soc_pkg::SRAMLength, soc_pkg::ROMLength, soc_pkg::DebugLength}),
  // cached region
  NrCachedRegionRules:   unsigned'(1),
  CachedRegionAddrBase:  1024'({soc_pkg::SRAMBase}),
  CachedRegionLength:    1024'({soc_pkg::SRAMLength}),
  MaxOutstandingStores:  unsigned'(7),
  DebugEn: bit'(1),
  NonIdemPotenceEn: bit'(0),
  AxiBurstWriteEn: bit'(0)
};

localparam type rvfi_instr_t = logic;


localparam NumWords = 16384;
localparam NBSlave = 2; // debug, cpu
localparam AxiAddrWidth = 64;
localparam AxiDataWidth = 64;
localparam AxiIdWidthMaster = 4;
localparam AxiIdWidthSlaves = AxiIdWidthMaster + $clog2(NBSlave); // 5
localparam AxiUserWidth = ariane_pkg::AXI_USER_WIDTH;
localparam AxiUserEn = ariane_pkg::AXI_USER_EN;

`AXI_TYPEDEF_ALL(axi_slave,
                 logic [    AxiAddrWidth-1:0],
                 logic [AxiIdWidthSlaves-1:0],
                 logic [    AxiDataWidth-1:0],
                 logic [(AxiDataWidth/8)-1:0],
                 logic [    AxiUserWidth-1:0])

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthMaster ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) slave[NBSlave-1:0]();

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) master[soc_pkg::NB_PERIPHERALS-1:0]();

// disable test-enable
logic test_en;
logic ndmreset;
logic ndmreset_n;
logic debug_req_irq;
logic timer_irq;
logic ipi;
logic rtc;
logic pll_locked;
assign pll_locked = rst_n;


// ROM
 logic                    rom_req;
 logic [AxiAddrWidth-1:0] rom_addr;
 logic [AxiDataWidth-1:0] rom_rdata;

// Debug
logic          debug_req_valid;
logic          debug_req_ready;
dm::dmi_req_t  debug_req;
logic          debug_resp_valid;
logic          debug_resp_ready;
dm::dmi_resp_t debug_resp;

logic dmactive;

// IRQ
logic [1:0] irq;
assign test_en    = 1'b0;

logic [NBSlave-1:0] pc_asserted;

rstgen i_rstgen_main (
    .clk_i        ( clk                      ),
    .rst_ni       ( pll_locked & (~ndmreset) ),
    .test_mode_i  ( test_en                  ),
    .rst_no       ( ndmreset_n               ),
    .init_no      (                          ) // keep open
);

// ---------------
// AXI Xbar
// ---------------

axi_pkg::xbar_rule_64_t [soc_pkg::NB_PERIPHERALS-1:0] addr_map;
//增加sram_1024_64_lx的addr_map
assign addr_map = '{
  '{ idx: soc_pkg::Debug,    start_addr: soc_pkg::DebugBase,    end_addr: soc_pkg::DebugBase + soc_pkg::DebugLength  },
  '{ idx: soc_pkg::ROM,      start_addr: soc_pkg::ROMBase,      end_addr: soc_pkg::ROMBase + soc_pkg::ROMLength      },
  '{ idx: soc_pkg::CLINT,    start_addr: soc_pkg::CLINTBase,    end_addr: soc_pkg::CLINTBase + soc_pkg::CLINTLength  },
  '{ idx: soc_pkg::PLIC,     start_addr: soc_pkg::PLICBase,     end_addr: soc_pkg::PLICBase + soc_pkg::PLICLength    },
  '{ idx: soc_pkg::Timer,    start_addr: soc_pkg::TimerBase,    end_addr: soc_pkg::TimerBase + soc_pkg::TimerLength  },
  '{ idx: soc_pkg::DCO,      start_addr: soc_pkg::DCOBase,      end_addr: soc_pkg::DCOBase + soc_pkg::DCOLength      },
  '{ idx: soc_pkg::CIM,      start_addr: soc_pkg::CIMBase,      end_addr: soc_pkg::CIMBase + soc_pkg::CIMLength      },
  '{ idx: soc_pkg::SRAM,     start_addr: soc_pkg::SRAMBase,     end_addr: soc_pkg::SRAMBase + soc_pkg::SRAMLength    },
  '{ idx: soc_pkg::SRAM_1024_64, start_addr: soc_pkg::SRAM_1024_64Base, end_addr: soc_pkg::SRAM_1024_64Base + soc_pkg::SRAM_1024_64Length}
};

localparam axi_pkg::xbar_cfg_t AXI_XBAR_CFG = '{
  NoSlvPorts:         soc_pkg::NrSlaves,
  NoMstPorts:         soc_pkg::NB_PERIPHERALS,
  MaxMstTrans:        1, // Probably requires update
  MaxSlvTrans:        1, // Probably requires update
  FallThrough:        1'b0,
  LatencyMode:        axi_pkg::CUT_ALL_PORTS,
  AxiIdWidthSlvPorts: AxiIdWidthMaster,
  AxiIdUsedSlvPorts:  AxiIdWidthMaster,
  UniqueIds:          1'b0,
  AxiAddrWidth:       AxiAddrWidth,
  AxiDataWidth:       AxiDataWidth,
  NoAddrRules:        soc_pkg::NB_PERIPHERALS
};

axi_xbar_intf #(
  .AXI_USER_WIDTH ( AxiUserWidth            ),
  .Cfg            ( AXI_XBAR_CFG            ),
  .rule_t         ( axi_pkg::xbar_rule_64_t )
) i_axi_xbar (
  .clk_i                 ( clk        ),
  .rst_ni                ( ndmreset_n ),
  .test_i                ( test_en    ),
  .slv_ports             ( slave      ),
  .mst_ports             ( master     ),
  .addr_map_i            ( addr_map   ),
  .en_default_mst_port_i ( '0         ),
  .default_mst_port_i    ( '0         )
);


// ---------------
// Debug Module
// ---------------
dmi_jtag i_dmi_jtag (
    .clk_i                ( clk                  ),
    .rst_ni               ( rst_n                ),
    .dmi_rst_no           (                      ), // keep open
    .testmode_i           ( test_en              ),
    .dmi_req_valid_o      ( debug_req_valid      ),
    .dmi_req_ready_i      ( debug_req_ready      ),
    .dmi_req_o            ( debug_req            ),
    .dmi_resp_valid_i     ( debug_resp_valid     ),
    .dmi_resp_ready_o     ( debug_resp_ready     ),
    .dmi_resp_i           ( debug_resp           ),
    .tck_i                ( tck    ),
    .tms_i                ( tms    ),
    .trst_ni              ( rst_n  ),
    .td_i                 ( tdi    ),
    .td_o                 ( tdo    ),
    .tdo_oe_o             (        )
);

ariane_axi::req_t    dm_axi_m_req;
ariane_axi::resp_t   dm_axi_m_resp;

logic                      dm_slave_req;
logic                      dm_slave_we;
logic [riscv::XLEN-1:0]    dm_slave_addr;
logic [riscv::XLEN/8-1:0]  dm_slave_be;
logic [riscv::XLEN-1:0]    dm_slave_wdata;
logic [riscv::XLEN-1:0]    dm_slave_rdata;

logic                      dm_master_req;
logic [riscv::XLEN-1:0]    dm_master_add;
logic                      dm_master_we;
logic [riscv::XLEN-1:0]    dm_master_wdata;
logic [riscv::XLEN/8-1:0]  dm_master_be;
logic                      dm_master_gnt;
logic                      dm_master_r_valid;
logic [riscv::XLEN-1:0]    dm_master_r_rdata;

// debug module
logic [63:0] dm_usr;
assign dm_usr = 64'b0;

dm_top #(
    .NrHarts          ( 1                 ),
    .BusWidth         ( riscv::XLEN       ),
    .SelectableHarts  ( 1'b1              )
) i_dm_top (
    .clk_i            ( clk               ),
    .rst_ni           ( rst_n             ), // PoR
    .testmode_i       ( test_en           ),
    .ndmreset_o       ( ndmreset          ),
    .dmactive_o       ( dmactive          ), // active debug session
    .debug_req_o      ( debug_req_irq     ),
    .unavailable_i    ( '0                ),
    .hartinfo_i       ( {ariane_pkg::DebugHartInfo} ),
    .slave_req_i      ( dm_slave_req      ),
    .slave_we_i       ( dm_slave_we       ),
    .slave_addr_i     ( dm_slave_addr     ),
    .slave_be_i       ( dm_slave_be       ),
    .slave_wdata_i    ( dm_slave_wdata    ),
    .slave_rdata_o    ( dm_slave_rdata    ),
    .master_req_o     ( dm_master_req     ),
    .master_add_o     ( dm_master_add     ),
    .master_we_o      ( dm_master_we      ),
    .master_wdata_o   ( dm_master_wdata   ),
    .master_be_o      ( dm_master_be      ),
    .master_gnt_i     ( dm_master_gnt     ),
    .master_r_valid_i ( dm_master_r_valid ),
    .master_r_rdata_i ( dm_master_r_rdata ),
    .dmi_rst_ni       ( rst_n             ),
    .dmi_req_valid_i  ( debug_req_valid   ),
    .dmi_req_ready_o  ( debug_req_ready   ),
    .dmi_req_i        ( debug_req         ),
    .dmi_resp_valid_o ( debug_resp_valid  ),
    .dmi_resp_ready_i ( debug_resp_ready  ),
    .dmi_resp_o       ( debug_resp        )
);

axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves    ),
    .AXI_ADDR_WIDTH ( riscv::XLEN         ),
    .AXI_DATA_WIDTH ( riscv::XLEN         ),
    .AXI_USER_WIDTH ( AxiUserWidth        )
) i_dm_axi2mem (
    .clk_i      ( clk                       ),
    .rst_ni     ( rst_n                     ),
    .slave      ( master[soc_pkg::Debug]    ),
    .req_o      ( dm_slave_req              ),
    .we_o       ( dm_slave_we               ),
    .addr_o     ( dm_slave_addr             ),
    .be_o       ( dm_slave_be               ),
    .data_o     ( dm_slave_wdata            ),
    .data_i     ( dm_slave_rdata            ),
    .user_i     ( dm_usr )
);

logic [1:0]    axi_adapter_size;

assign axi_adapter_size = (riscv::XLEN == 64) ? 2'b11 : 2'b10;

axi_adapter #(
    .CVA6Cfg               ( CVA6Cfg                  ),
    .DATA_WIDTH            ( riscv::XLEN              ),
    .axi_req_t             ( ariane_axi::req_t        ),
    .axi_rsp_t             ( ariane_axi::resp_t       )
) i_dm_axi_master (
    .clk_i                 ( clk                       ),
    .rst_ni                ( rst_n                     ),
    .req_i                 ( dm_master_req             ),
    .type_i                ( ariane_pkg::SINGLE_REQ    ),
    .amo_i                 ( ariane_pkg::AMO_NONE      ),
    .gnt_o                 ( dm_master_gnt             ),
    .addr_i                ( dm_master_add             ),
    .we_i                  ( dm_master_we              ),
    .wdata_i               ( dm_master_wdata           ),
    .be_i                  ( dm_master_be              ),
    .size_i                ( axi_adapter_size          ),
    .id_i                  ( '0                        ),
    .valid_o               ( dm_master_r_valid         ),
    .rdata_o               ( dm_master_r_rdata         ),
    .id_o                  (                           ),
    .critical_word_o       (                           ),
    .critical_word_valid_o (                           ),
    .axi_req_o             ( dm_axi_m_req              ),
    .axi_resp_i            ( dm_axi_m_resp             )
);

    `AXI_ASSIGN_FROM_REQ(slave[1], dm_axi_m_req)
    `AXI_ASSIGN_TO_RESP(dm_axi_m_resp, slave[1])


// ---------------
// Core
// ---------------
ariane_axi::req_t    axi_ariane_req;
ariane_axi::resp_t   axi_ariane_resp;

cva6 #(
    .CVA6Cfg ( CVA6Cfg ),
    .IsRVFI ( IsRVFI ),
    .rvfi_instr_t ( rvfi_instr_t )
) i_cpu (
    .clk_i        ( clk                 ),
    .rst_ni       ( ndmreset_n          ),
    .boot_addr_i  ( soc_pkg::ROMBase    ), // start fetching from ROM 
    // .boot_addr_i  ( 64'h80000024       ), // start fetching from SRAM 
    .hart_id_i    ( '0                  ),
    .irq_i        ( irq                 ),
    .ipi_i        ( ipi                 ),
    .time_irq_i   ( timer_irq           ),
    .rvfi_o       ( /* open */          ),
    .debug_req_i  ( debug_req_irq       ),
    .noc_req_o    ( axi_ariane_req      ),
    .noc_resp_i   ( axi_ariane_resp     )
);

`AXI_ASSIGN_FROM_REQ(slave[0], axi_ariane_req)
`AXI_ASSIGN_TO_RESP(axi_ariane_resp, slave[0])


// ---------------
// CLINT
// ---------------
// divide clock by two
always_ff @(posedge clk or negedge ndmreset_n) begin
  if (~ndmreset_n) begin
    rtc <= 0;
  end else begin
    rtc <= rtc ^ 1'b1;
  end
end

  ariane_axi_soc::req_slv_t  axi_clint_req;
  ariane_axi_soc::resp_slv_t axi_clint_resp;

clint #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .NR_CORES       ( 1                ),
    .axi_req_t      ( ariane_axi_soc::req_slv_t    ),
    .axi_resp_t     ( ariane_axi_soc::resp_slv_t   )
) i_clint (
    .clk_i       ( clk            ),
    .rst_ni      ( ndmreset_n     ),
    .testmode_i  ( test_en        ),
    .axi_req_i   ( axi_clint_req  ),
    .axi_resp_o  ( axi_clint_resp ),
    .rtc_i       ( rtc            ),
    .timer_irq_o ( timer_irq      ),
    .ipi_o       ( ipi            )
);

`AXI_ASSIGN_TO_REQ(axi_clint_req, master[soc_pkg::CLINT])
`AXI_ASSIGN_FROM_RESP(master[soc_pkg::CLINT], axi_clint_resp)


// ---------------
// ROM
// ---------------
logic [63:0] rom_usr;
assign rom_usr = 64'b0;

axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) i_axi2rom (
    .clk_i  ( clk                     ),
    .rst_ni ( ndmreset_n              ),
    .slave  ( master[soc_pkg::ROM]    ),
    .req_o  ( rom_req                 ),
    .we_o   (                         ),
    .addr_o ( rom_addr                ),
    .be_o   (                         ),
    .data_o (                         ),
    .data_i ( rom_rdata               ),
    .user_i ( rom_usr )
);

bootrom i_bootrom (
.clk_i      ( clk       ),
.req_i      ( rom_req   ),
.addr_i     ( rom_addr  ),
.rdata_o    ( rom_rdata )
);


// ------------------------------
// Memory (SRAM)
// ------------------------------

logic                       req;
logic                       we;
logic [AxiAddrWidth-1:0]    addr;
logic [AxiDataWidth/8-1:0]  be;
logic [AxiDataWidth-1:0]    wdata;
logic [AxiDataWidth-1:0]    rdata;
logic [AxiUserWidth-1:0]    wuser;
logic [AxiUserWidth-1:0]    ruser;

axi2mem #(
.AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
.AXI_ADDR_WIDTH ( AxiAddrWidth     ),
.AXI_DATA_WIDTH ( AxiDataWidth     ),
.AXI_USER_WIDTH ( AxiUserWidth     )
) i_axi2mem (
.clk_i  ( clk          ),
.rst_ni ( ndmreset_n   ),
.slave  ( master[soc_pkg::SRAM] ),
.req_o  ( req          ),
.we_o   ( we           ),
.addr_o ( addr         ),
.be_o   ( be           ),
.user_o ( wuser        ),
.data_o ( wdata        ),
.user_i ( ruser        ),
.data_i ( rdata        )
);

`ifdef SIM
sram #(
    .DATA_WIDTH ( AxiDataWidth ),
    .USER_EN    ( 0 ),
    .SIM_INIT   ( "file" ), //改成none? 在tb中用readmemh载入hex。最开始是file
    .NUM_WORDS  ( NumWords )
) i_sram (
    .clk_i      ( clk               ),
    .rst_ni     ( ndmreset_n        ),
    .req_i      ( req               ),
    .we_i       ( we                ),
    .addr_i     ( addr[$clog2(NumWords)-1+$clog2(AxiDataWidth/8):$clog2(AxiDataWidth/8)] ),
    .wuser_i    ( wuser             ),
    .wdata_i    ( wdata             ),
    .be_i       ( be                ),
    .ruser_o    ( ruser             ),
    .rdata_o    ( rdata             )
);
`else
logic [63:0] sram_wen;

genvar i;
generate
    for (i = 0; i < 8; i = i + 1)
    begin: gen_sram_wen
        assign sram_wen[i*8 +: 8] = {8{we & be[i]}};
    end
endgenerate

sram1024x64 i_sram(
    .CLK(clk),
    .CEN(~req),
    .GWEN(~we),
    .WEN(~sram_wen),
    .A(addr[$clog2(NumWords)-1+$clog2(AxiDataWidth/8):$clog2(AxiDataWidth/8)]),
    .D(wdata),
    .Q(rdata),
    .STOV(1'b0),
    .EMA (3'b100),
    .EMAW(2'b00),
    .EMAS(1'b0),
    .RET1N(1'b1),
    .RAWL(1'b0),
    .RAWLM(2'b00),
    .WABL(1'b1),
    .WABLM(3'b001)
);

assign ruser = 64'b0;
`endif

// ---------------
// 使用 sram_1024_64_wrapper 挂载 SRAM (sram_1024_64_lx, 64-bit) 
// ---------------
logic                       sram_req;
logic                       sram_we;
logic [AxiAddrWidth-1:0]    sram_addr;
logic [AxiDataWidth/8-1:0]  sram_be;
logic [AxiDataWidth-1:0]    sram_wdata;
logic [AxiDataWidth-1:0]    sram_rdata;
logic [AxiUserWidth-1:0]    sram_ruser;

assign sram_ruser = '0;

axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) i_axi2sram (
    .clk_i  ( clk                     ),
    .rst_ni ( ndmreset_n              ),
    .slave  ( master[soc_pkg::SRAM_1024_64]   ),
    .req_o  ( sram_req                ),
    .we_o   ( sram_we                 ),
    .addr_o ( sram_addr               ),
    .be_o   ( sram_be                 ),
    .user_o (                         ),
    .data_o ( sram_wdata              ),
    .user_i ( sram_ruser              ),
    .data_i ( sram_rdata              )
);

sram_1024_64_wrapper #(
    .AXI_ADDR_WIDTH   ( AxiAddrWidth   ),
    .AXI_DATA_WIDTH   ( AxiDataWidth   ),
    .AXI_ADDR_OFFSET  ( 3              ),
    .NUM_MACROS       ( 1              ),
    .MACRO_ADDR_WIDTH ( 10             )
) i_sram_1024_64_wrapper (
    .clk_i           ( clk             ),
    .rstn_i          ( ndmreset_n      ),
    .axi_req_i       ( sram_req        ),
    .axi_write_en_i  ( sram_we         ),
    .axi_addr_i      ( sram_addr       ),
    .axi_byte_en_i   ( sram_be         ),
    .axi_wdata_i     ( sram_wdata      ),
    .axi_rdata_o     ( sram_rdata      )
);

// ---------------
// DCO
// ---------------

// Here we demonstrate the use of datawidth converter.
// In addition to the master[soc_pkg::DCO] AXI_BUS instantiated earlier, we have to instantiate another AXI_BUS to use the converter.
                                                                                          
localparam DCORegBusDataWidth = 32;

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth        ),
    .AXI_DATA_WIDTH ( DCORegBusDataWidth  ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves    ),
    .AXI_USER_WIDTH ( AxiUserWidth        )
) i_axi_bus_DCO();

axi_dw_converter_intf #(
    .AXI_ID_WIDTH            ( AxiIdWidthSlaves   ),
    .AXI_ADDR_WIDTH          ( AxiAddrWidth       ),
    .AXI_SLV_PORT_DATA_WIDTH ( AxiDataWidth       ),  // Here the slave port faces the AXI XBar
    .AXI_MST_PORT_DATA_WIDTH ( DCORegBusDataWidth ),  // Here the master port faces the DCO (Reg bus)
    .AXI_USER_WIDTH          ( AxiUserWidth       )
) i_axi_dw_converter_dco (
    .clk_i                 ( clk                     ),
    .rst_ni                ( ndmreset_n              ),
    .slv                   ( master[soc_pkg::DCO]    ),
    .mst                   ( i_axi_bus_DCO           )
);

REG_BUS #(
    .ADDR_WIDTH   ( AxiAddrWidth ),
  .DATA_WIDTH   ( DCORegBusDataWidth )
  ) i_reg_bus_DCO (clk);

axi_to_reg_intf #(
  .ADDR_WIDTH          (AxiAddrWidth        ),
  .DATA_WIDTH          (DCORegBusDataWidth  ),
  .ID_WIDTH            (AxiIdWidthSlaves    ),
  .USER_WIDTH          (AxiUserWidth        )
)  i_axi_to_DCO_reg_intf(
    .clk_i               (clk),
    .rst_ni              (ndmreset_n),
    .testmode_i          (1'b0),
    .in                  (i_axi_bus_DCO),  // If we don't need to convert data width, we can use master[soc_pkg::DCO] here.
    .reg_o               (i_reg_bus_DCO)
);

// name, type of addr, type of wdata, type of wstrb
`REG_BUS_TYPEDEF_ALL(DCO_reg, logic[63:0], logic[31:0], logic[3:0])
DCO_reg_req_t DCO_reg_req;
DCO_reg_rsp_t DCO_reg_rsp;

// assign REG_BUS.out to (req_t, rsp_t) pair
`REG_BUS_ASSIGN_TO_REQ(DCO_reg_req, i_reg_bus_DCO)
`REG_BUS_ASSIGN_FROM_RSP(i_reg_bus_DCO, DCO_reg_rsp)

logic [5:0] dco_cc_sel;
logic [5:0] dco_fc_sel;
logic [2:0] dco_div_sel;
logic [1:0] dco_freq_sel;

`ifdef SIM
assign dco_cc_sel_o = dco_cc_sel;
assign dco_fc_sel_o = dco_fc_sel;
assign dco_div_sel_o = dco_div_sel;
assign dco_freq_sel_o = dco_freq_sel;
`endif

DCO_regs #(
    .reg_req_t (DCO_reg_req_t),
    .reg_rsp_t (DCO_reg_rsp_t)
) i_DCO_regs(
    .clk        (clk),
    .rst_n      (ndmreset_n),
    .cc_sel_o   (dco_cc_sel),
    .fc_sel_o   (dco_fc_sel), 
    .freq_sel_o (dco_freq_sel), 
    .div_sel_o  (dco_div_sel), 

    .req_i      (DCO_reg_req),
    .rsp_o      (DCO_reg_rsp)
);


`ifndef SIM
DCO i_dco(
    .EN       (dco_en),
    .CC_SEL   (dco_cc_sel),
    .FC_SEL   (dco_fc_sel),
    .EXT_CLK  (ext_clk),
    .CLK_SEL  (clk_sel),
    .DIV_SEL  (dco_div_sel),
    .FREQ_SEL (dco_freq_sel),
    .CLK      (dco_clk_o),    // not connected yet for simulation
    .CLK_DIV  (dco_clk_div_o),
    .RSTN     (div_rst_n)
);

assign clk = dco_clk_o;
`endif

// ---------------
// Peripherals
// ---------------
peripheral #(
    .AxiAddrWidth ( AxiAddrWidth     ),
    .AxiDataWidth ( AxiDataWidth     ),
    .AxiIdWidth   ( AxiIdWidthSlaves ),
    .AxiUserWidth ( AxiUserWidth     )
) i_peripheral (
    .clk_i        ( clk                   ),
    .rst_ni       ( ndmreset_n            ),
    .plic         ( master[soc_pkg::PLIC] ),
    .timer        ( master[soc_pkg::Timer]),
    .irq_o        ( irq                   )
);


// ---------------------
// Clock Detector
// ---------------------
logic [31:0] timer_cnt;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        clk_led <= 1'b0;
        timer_cnt <= 32'd0;
    end
    else if (timer_cnt == 32'd9_999_999)
    begin
        clk_led <= ~clk_led;
        timer_cnt <= 32'd0;
    end
    else
    begin
        clk_led <= clk_led;
        timer_cnt <= timer_cnt + 32'd1;
    end
end


endmodule
