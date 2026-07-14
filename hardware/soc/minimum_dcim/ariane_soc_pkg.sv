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
// Description: Contains SoC information as constants
package ariane_soc;
  // M-Mode Hart, S-Mode Hart
  localparam int unsigned NumTargets = 2;
  // Uart, SPI, Ethernet, reserved
  localparam int unsigned NumSources = 30;
  localparam int unsigned MaxPriority = 7;

  typedef enum int unsigned {
    AraMst   = 0,
    DebugMst = 1,
    NrSlaves = 2  // actually masters, but slaves on the crossbar
  } axi_masters_t;

  typedef enum int unsigned {
    DRAM     = 0,
    GPIO     = 1,
    Timer    = 2,
    UART     = 3,
    PLIC     = 4,
    CLINT    = 5,
    ROM      = 6,
    Debug    = 7,
    Ctrl     = 8,
    DefaultSlave = 9,
	// Add DCIM ENUM
	DCIM	 = 10,
    NB_PERIPHERALS = 11
  } axi_slaves_t;

  localparam logic[63:0] DebugLength    = 64'h1000;
  localparam logic[63:0] ROMLength      = 64'h10000;
  localparam logic[63:0] CLINTLength    = 64'hC0000;
  localparam logic[63:0] PLICLength     = 64'h3FF_FFFF;
  localparam logic[63:0] UARTLength     = 64'h1000;
  localparam logic[63:0] TimerLength    = 64'h1000;
  localparam logic[63:0] GPIOLength     = 64'h1000;
  localparam logic[63:0] CtrlLength     = 64'h1000;
  localparam logic[63:0] DefaultSlaveLength = 64'h1000;

  localparam logic[63:0] DRAMLength     = 64'h2_0000; // 128 kB

  // MMIO window: ctrl + cfg + act/out/wei regions (adapt_decode uses axi_addr[19:17])
  localparam logic[63:0] DCIMLength		= 64'hA0000;	// 640 KiB

  typedef enum logic [63:0] {
    DebugBase    = 64'h0000_0000,
    ROMBase      = 64'h0001_0000,
    CLINTBase    = 64'h0200_0000,
    PLICBase     = 64'h0C00_0000,
    UARTBase     = 64'h1000_0000,
    TimerBase    = 64'h1800_0000,
    GPIOBase     = 64'h4000_0000,
    DefaultSlaveBase = 64'h5000_0000,
    DRAMBase     = 64'h8000_0000,
    CtrlBase     = 64'hD000_0000,

	// Add DCIM Base Address
	DCIMBase	 = 64'hE000_0000
  } soc_bus_start_t;

  localparam NrRegion = 1;
  localparam logic [NrRegion-1:0][NB_PERIPHERALS-1:0] ValidRule = {{NrRegion * NB_PERIPHERALS}{1'b1}};

endpackage
