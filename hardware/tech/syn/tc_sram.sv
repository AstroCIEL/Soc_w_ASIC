// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Synthesis wrapper for tc_sram.
// Routes each (NumWords, DataWidth) shape to the corresponding SRAM macro.
// Unknown shapes trigger an elaboration-time $fatal.
//
// Known shapes (from sram.txt):
//    16384 ×  64  — L2 main memory (128 kB, AXI_DATA_WIDTH=64b / NrLanes=2)
//       64 × 256  — D$ data bank
//       64 × 128  — I$ data
//       64 ×  64  — Ara VRF bank
//       64 ×  47  — I$ tag
//       64 ×  46  — D$ tag

module tc_sram #(
  parameter int unsigned NumWords     = 32'd1024,
  parameter int unsigned DataWidth    = 32'd128,
  parameter int unsigned ByteWidth    = 32'd8,
  parameter int unsigned NumPorts     = 32'd2,
  parameter int unsigned Latency      = 32'd1,
  parameter              SimInit      = "none",
  parameter bit          PrintSimCfg  = 1'b0,
  parameter              ImplKey      = "none",
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o
);

  // All known macros are single-port, latency-1
  if (NumPorts != 1) begin : gen_err_ports
    $fatal(1, "tc_sram_syn: NumPorts=%0d not supported (only 1-port macros available)", NumPorts);
  end
  if (Latency != 1) begin : gen_err_latency
    $fatal(1, "tc_sram_syn: Latency=%0d not supported (only latency-1 macros available)", Latency);
  end

  // ── Shape dispatch ───────────────────────────────────────────────────────
  if (NumWords == 16384 && DataWidth == 64) begin : gen_l2_mem
    // L2 main memory — 16384 × 64b  
    logic [63:0] wen_bits;
    for (genvar i = 0; i < 8; i++) begin : gen_wen_expand
      assign wen_bits[i*8 +: 8] = {8{~be_i[0][i]}};
    end

    sram_l2_16384x64 i_macro (
      .CLK   (clk_i        ),
      .CEN   (~req_i[0]    ),       // active-low chip enable
      .GWEN  (~we_i[0]     ),       // active-low global write enable
      .A     (addr_i[0]    ),
      .D     (wdata_i[0]   ),
      .WEN   (wen_bits     ),       // active-low bit write mask
      .Q     (rdata_o[0]   ),
      // margin / retention / debug signals — fixed at default values
      .STOV  (1'b0         ),       // debug, tie-off 0
      .RET1N (1'b1         ),       // 1 = normal mode (0 = low-power retention)
      .EMA   (3'b100       ),       // SS/low-voltage corner timing margin (model reference value)
      .EMAW  (2'b00        ),       // SS/low-voltage corner write margin (model reference value)
      .EMAS  (1'b0         ),       // SS/low-voltage corner (model reference value)
      .RAWL  (1'b0         ),       // read-assist off (default)
      .RAWLM (2'b00        ),       // read-assist mode bits (default)
      .WABL  (1'b1         ),       // write-assist bypass (STA: selects valid addr setup arc)
      .WABLM (2'b01       )        // write-assist mode bits (default)
    );
//TODO：需要检查这个WABLM的值


  end else if (NumWords == 64 && DataWidth == 256) begin : gen_dcache_data
    // D$ data bank — 64 × 256b
    logic [127:0] wen_lo, wen_hi;
    for (genvar i = 0; i < 16; i++) begin : gen_dcache_wen_expand
      assign wen_lo[i*8 +: 8] = {8{~be_i[0][i   ]}};
      assign wen_hi[i*8 +: 8] = {8{~be_i[0][i+16]}};
    end

    rf_dcache_half_64x128 i_macro_lo (
      .clk   (clk_i              ),
      .cen   (~req_i[0]          ),        // active-low chip enable
      .gwen  (~we_i[0]           ),        // active-low global write enable
      .a     (addr_i[0]          ),
      .d     (wdata_i[0][127:0]  ),
      .wen   (wen_lo             ),        // active-low bit write mask
      .q     (rdata_o[0][127:0]  ),
      // margin / retention signals — fixed at default values
      .ema   (3'b100             ),        // SS/low-voltage corner timing margin (model reference value)
      .emaw  (2'b00              ),        // SS/low-voltage corner write margin (model reference value)
      .emas  (1'b0               ),        // SS/low-voltage corner (model reference value)
      .ret1n (1'b1               ),        // 1 = normal mode (0 = low-power retention)
      .rawl  (1'b0               ),        // read-assist off (default)
      .rawlm (2'b00              ),        // read-assist mode bits (default)
      .wabl  (1'b1               ),        // write-assist bypass (STA: selects valid addr setup arc)
      .wablm (2'b01              )         // write-assist mode bits (default)
    );

    rf_dcache_half_64x128 i_macro_hi (
      .clk   (clk_i              ),
      .cen   (~req_i[0]          ),        // active-low chip enable
      .gwen  (~we_i[0]           ),        // active-low global write enable
      .a     (addr_i[0]          ),
      .d     (wdata_i[0][255:128]),
      .wen   (wen_hi             ),        // active-low bit write mask
      .q     (rdata_o[0][255:128]),
      // margin / retention signals — fixed at default values
      .ema   (3'b100             ),        // SS/low-voltage corner timing margin (model reference value)
      .emaw  (2'b00              ),        // SS/low-voltage corner write margin (model reference value)
      .emas  (1'b0               ),        // SS/low-voltage corner (model reference value)
      .ret1n (1'b1               ),        // 1 = normal mode (0 = low-power retention)
      .rawl  (1'b0               ),        // read-assist off (default)
      .rawlm (2'b00              ),        // read-assist mode bits (default)
      .wabl  (1'b1               ),        // write-assist bypass (STA: selects valid addr setup arc)
      .wablm (2'b01              )         // write-assist mode bits (default)
    );

  end else if (NumWords == 64 && DataWidth == 128) begin : gen_icache_data
    // I$ data — 64 × 128b.
    logic [127:0] wen_bits;
    for (genvar i = 0; i < 16; i++) begin : gen_icache_wen_expand
      assign wen_bits[i*8 +: 8] = {8{~be_i[0][i]}};
    end

    rf_icache_64x128 i_macro (
      .clk   (clk_i        ),
      .cen   (~req_i[0]    ),        // active-low chip enable
      .gwen  (~we_i[0]     ),        // active-low global write enable
      .a     (addr_i[0]    ),
      .d     (wdata_i[0]   ),
      .wen   (wen_bits     ),        // active-low bit write mask
      .q     (rdata_o[0]   ),
      // margin / retention signals — fixed at default values
      .ema   (3'b100       ),        // SS/low-voltage corner timing margin (model reference value)
      .emaw  (2'b00        ),        // SS/low-voltage corner write margin (model reference value)
      .emas  (1'b0         ),        // SS/low-voltage corner (model reference value)
      .ret1n (1'b1         ),        // 1 = normal mode (0 = low-power retention)
      .rawl  (1'b0         ),        // read-assist off (default)
      .rawlm (2'b00        ),        // read-assist mode bits (default)
      .wabl  (1'b1         ),        // write-assist bypass (STA: selects valid addr setup arc)
      .wablm (2'b01        )         // write-assist mode bits (default)
    );

  end else if (NumWords == 64 && DataWidth == 64) begin : gen_vrf
    // Ara VRF bank — 64 × 64b.
    logic [63:0] wen_bits;
    for (genvar i = 0; i < 8; i++) begin : gen_vrf_wen_expand
      assign wen_bits[i*8 +: 8] = {8{~be_i[0][i]}};
    end

    rf_vrf_64x64 i_macro (
      .clk   (clk_i        ),
      .cen   (~req_i[0]    ),        // active-low chip enable
      .gwen  (~we_i[0]     ),        // active-low global write enable
      .a     (addr_i[0]    ),
      .d     (wdata_i[0]   ),
      .wen   (wen_bits     ),        // active-low bit write mask
      .q     (rdata_o[0]   ),
      // margin / retention signals — fixed at default values
      .ema   (3'b100       ),        // SS/low-voltage corner timing margin (model reference value)
      .emaw  (2'b00        ),        // SS/low-voltage corner write margin (model reference value)
      .emas  (1'b0         ),        // SS/low-voltage corner (model reference value)
      .ret1n (1'b1         ),        // 1 = normal mode (0 = low-power retention)
      .rawl  (1'b0         ),        // read-assist off (default)
      .rawlm (2'b00        ),        // read-assist mode bits (default)
      .wabl  (1'b1         ),        // write-assist bypass (STA: selects valid addr setup arc)
      .wablm (2'b01        )         // write-assist mode bits (default)
    );

  end else if (NumWords == 64 && DataWidth == 47) begin : gen_icache_tag
    // I$ tag — 64 × 47b  
    logic [47:0] wen_bits;
    logic [47:0] q_raw;
    for (genvar i = 0; i < 5; i++) begin : gen_itag_wen_expand
      assign wen_bits[i*8 +: 8] = {8{~be_i[0][i]}};
    end
    assign wen_bits[46:40] = {7{~be_i[0][5]}};
    assign wen_bits[47]    = 1'b1;             // unused macro bit — write always masked

    rf_icache_tag_64x48 i_macro (
      .clk   (clk_i                  ),
      .cen   (~req_i[0]              ),        // active-low chip enable
      .gwen  (~we_i[0]               ),        // active-low global write enable
      .a     (addr_i[0]              ),
      .d     ({1'b0, wdata_i[0]}     ),        // pad unused bit [47] with 0
      .wen   (wen_bits               ),        // active-low bit write mask
      .q     (q_raw                  ),        // 48-bit output
      // margin / retention signals — fixed at default values
      .ema   (3'b100                 ),        // SS/low-voltage corner timing margin (model reference value)
      .emaw  (2'b00                  ),        // SS/low-voltage corner write margin (model reference value)
      .emas  (1'b0                   ),        // SS/low-voltage corner (model reference value)
      .ret1n (1'b1                   ),        // 1 = normal mode (0 = low-power retention)
      .rawl  (1'b0                   ),        // read-assist off (default)
      .rawlm (2'b00                  ),        // read-assist mode bits (default)
      .wabl  (1'b1                   ),        // write-assist bypass (STA: selects valid addr setup arc)
      .wablm (2'b01                  )         // write-assist mode bits (default)
    );

    assign rdata_o[0] = q_raw[46:0];          // discard unused bit [47]

  end else if (NumWords == 64 && DataWidth == 46) begin : gen_dcache_tag
    // D$ tag — 64 × 46b 
    logic [45:0] wen_bits;
    for (genvar i = 0; i < 5; i++) begin : gen_dtag_wen_expand
      assign wen_bits[i*8 +: 8] = {8{~be_i[0][i]}};
    end
    assign wen_bits[45:40] = {6{~be_i[0][5]}};

    rf_dcache_tag_64x46 i_macro (
      .clk   (clk_i        ),
      .cen   (~req_i[0]    ),        // active-low chip enable
      .gwen  (~we_i[0]     ),        // active-low global write enable
      .a     (addr_i[0]    ),
      .d     (wdata_i[0]   ),
      .wen   (wen_bits     ),        // active-low bit write mask
      .q     (rdata_o[0]   ),
      // margin / retention signals — fixed at default values
      .ema   (3'b100       ),        // SS/low-voltage corner timing margin (model reference value)
      .emaw  (2'b00        ),        // SS/low-voltage corner write margin (model reference value)
      .emas  (1'b0         ),        // SS/low-voltage corner (model reference value)
      .ret1n (1'b1         ),        // 1 = normal mode (0 = low-power retention)
      .rawl  (1'b0         ),        // read-assist off (default)
      .rawlm (2'b00        ),        // read-assist mode bits (default)
      .wabl  (1'b1         ),        // write-assist bypass (STA: selects valid addr setup arc)
      .wablm (2'b01        )         // write-assist mode bits (default)
    );

  end else begin : gen_err_shape
    $fatal(1, "tc_sram_syn: unsupported shape NumWords=%0d DataWidth=%0d — add a new macro branch",
           NumWords, DataWidth);
  end

endmodule
