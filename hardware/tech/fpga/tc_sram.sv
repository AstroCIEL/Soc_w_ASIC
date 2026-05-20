// FPGA (Xilinx) implementation of tc_sram.
// Uses Xilinx-recommended coding style for BRAM/URAM inference with byte-enable.
// Vivado will automatically map to Block RAM or Ultra RAM depending on size.
//
// Known shapes (from sram-report.txt):
//    16384 ×  64  — L2 main memory (128 kB, AXI_DATA_WIDTH=64b / NrLanes=2)
//       64 × 256  — D$ data bank
//       64 × 128  — I$ data
//       64 ×  64  — Ara VRF bank
//       64 ×  47  — I$ tag
//       64 ×  46  — D$ tag

module tc_sram #(
  parameter int unsigned NumWords     = 32'd1024, // Number of Words in data array
  parameter int unsigned DataWidth    = 32'd128,  // Data signal width
  parameter int unsigned ByteWidth    = 32'd8,    // Width of a data byte
  parameter int unsigned NumPorts     = 32'd2,    // Number of read and write ports
  parameter int unsigned Latency      = 32'd1,    // Latency when the read data is available
  parameter              SimInit      = "none",   // Simulation initialization
  parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
  parameter              ImplKey      = "none",   // Reference to specific implementation
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,      // Clock
  input  logic                 rst_ni,     // Asynchronous reset active low
  // input ports
  input  logic  [NumPorts-1:0] req_i,      // request
  input  logic  [NumPorts-1:0] we_i,       // write enable
  input  addr_t [NumPorts-1:0] addr_i,     // request address
  input  data_t [NumPorts-1:0] wdata_i,    // write data
  input  be_t   [NumPorts-1:0] be_i,       // write byte enable
  // output ports
  output data_t [NumPorts-1:0] rdata_o     // read data
);

  // ── Shape validation ──────────────────────────────────────────────────────
  // All known macros are single-port, latency-1
  if (NumPorts != 1) begin : gen_err_ports
    $fatal(1, "tc_sram_fpga: NumPorts=%0d not supported (only 1-port BRAM available)", NumPorts);
  end
  if (Latency != 1) begin : gen_err_latency
    $fatal(1, "tc_sram_fpga: Latency=%0d not supported (only latency-1 BRAM available)", Latency);
  end

  // Check known shapes
  if (!((NumWords == 16384 && DataWidth == 64)  ||  // L2 memory
        (NumWords == 64    && DataWidth == 256) ||  // D$ data bank
        (NumWords == 64    && DataWidth == 128) ||  // I$ data
        (NumWords == 64    && DataWidth == 64)  ||  // Ara VRF bank
        (NumWords == 64    && DataWidth == 47)  ||  // I$ tag
        (NumWords == 64    && DataWidth == 46)))    // D$ tag
  begin : gen_err_shape
    $fatal(1, "tc_sram_fpga: unsupported shape NumWords=%0d DataWidth=%0d — add a new BRAM branch",
           NumWords, DataWidth);
  end

  // ── BRAM instantiation using Xilinx XPM ───────────────────────────────────
  // xpm_memory_spram: Single-Port RAM, maps to BRAM or URAM automatically.
  // Requires: `include "xpm_memory.sv"` or Vivado library auto-linking.

  // XPM constraint: WRITE_DATA_WIDTH_A must be a multiple of BYTE_WRITE_WIDTH_A.
  // For non-byte-aligned widths (e.g. tag SRAMs: 47b, 46b), fall back to
  // whole-word write (BYTE_WRITE_WIDTH_A = DataWidth, single-bit WEA).
  localparam int unsigned ByteAligned    = (DataWidth % ByteWidth == 0) ? 1 : 0;
  localparam int unsigned XpmByteWidth   = ByteAligned ? ByteWidth : DataWidth;
  localparam int unsigned XpmWeaWidth    = DataWidth / XpmByteWidth; // = BeWidth or 1

  logic [DataWidth-1:0] dout;
  assign rdata_o[0] = dout;

  // WEA generation: byte-aligned uses per-byte enables; otherwise single-bit
  logic [XpmWeaWidth-1:0] wea;
  if (ByteAligned) begin : gen_wea_byte
    assign wea = {BeWidth{we_i[0]}} & be_i[0];
  end else begin : gen_wea_word
    assign wea = we_i[0];
  end

  xpm_memory_spram #(
    .ADDR_WIDTH_A       (AddrWidth),
    .AUTO_SLEEP_TIME    (0),
    .BYTE_WRITE_WIDTH_A (XpmByteWidth),
    .CASCADE_HEIGHT     (0),
    .ECC_BIT_RANGE      ("7:0"),
    .ECC_MODE           ("no_ecc"),
    .ECC_TYPE           ("none"),
    .IGNORE_INIT_SYNTH  (0),
    .MEMORY_INIT_FILE   ("none"),
    .MEMORY_INIT_PARAM  ("0"),
    .MEMORY_OPTIMIZATION("true"),
    .MEMORY_PRIMITIVE   ("auto"),       // auto selects BRAM or URAM
    .MEMORY_SIZE        (NumWords * DataWidth),
    .MESSAGE_CONTROL    (0),
    .RAM_DECOMP         ("auto"),
    .READ_DATA_WIDTH_A  (DataWidth),
    .READ_LATENCY_A     (1),
    .READ_RESET_VALUE_A ("0"),
    .RST_MODE_A         ("SYNC"),
    .SIM_ASSERT_CHK     (0),
    .USE_MEM_INIT       (0),
    .USE_MEM_INIT_MMI   (0),
    .WAKEUP_TIME        ("disable_sleep"),
    .WRITE_DATA_WIDTH_A (DataWidth),
    .WRITE_MODE_A       ("read_first"),
    .WRITE_PROTECT      (1)
  ) i_xpm_mem (
    .clka           (clk_i),
    .rsta           (~rst_ni),
    .ena            (req_i[0]),
    .wea            (wea),
    .addra          (addr_i[0]),
    .dina           (wdata_i[0]),
    .douta          (dout),
    .regcea         (1'b1),
    .injectsbiterra (1'b0),
    .injectdbiterra (1'b0),
    .sbiterra       (),
    .dbiterra       (),
    .sleep          (1'b0)
  );

endmodule
