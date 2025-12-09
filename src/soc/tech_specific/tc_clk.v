// Copyright 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// Modifier: Mingxuan Li <mingxuanli_siris@163.com> [Peking University]

module tc_clk_and2 (
  input  wire clk0_i,
  input  wire clk1_i,
  output wire clk_o
);

`ifdef SVT
  CKAN2CTD8BWP6T16P96CPD clock_and2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`elsif LVT
  CKAN2CTD8BWP6T16P96CPDLVT clock_and2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`elsif ULVT
  CKAN2CTD8BWP6T16P96CPDULVT clock_and2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`endif

endmodule

module tc_clk_buffer (
  input  wire clk_i,
  output wire clk_o
);

`ifdef SVT
  DCCKBCTD6BWP6T16P96CPD clock_buffer_inst (
    .I    (clk_i),
    .Z    (clk_o)
  );
`elsif LVT
  DCCKBCTD6BWP6T16P96CPDLVT clock_buffer_inst (
    .I    (clk_i),
    .Z    (clk_o)
  );
`elsif ULVT
  DCCKBCTD6BWP6T16P96CPDULVT clock_buffer_inst (
    .I    (clk_i),
    .Z    (clk_o)
  );
`endif

endmodule

// Description: Behavioral model of an integrated clock-gating cell (ICG)
module tc_clk_gating #(
  /// This paramaeter is a hint for tool/technology specific mappings of this
  /// tech_cell. It indicates wether this particular clk gate instance is
  /// required for functional correctness or just instantiated for power
  /// savings. If IS_FUNCTIONAL == 0, technology specific mappings might
  /// replace this cell with a feedthrough connection without any gating.
  parameter bit IS_FUNCTIONAL = 1'b1
)(
   input  wire clk_i,
   input  wire en_i,
   input  wire test_en_i,
   output wire clk_o
);

`ifdef SVT
  CKLNQCTD10BWP6T16P96CPD clock_gate_inst (
    .TE    ( test_en_i ),
    .E     ( en_i      ),
    .CP    ( clk_i     ),
    .Q     ( clk_o     )
  );
`elsif LVT
  CKLNQCTD10BWP6T16P96CPDLVT clock_gate_inst (
    .TE    ( test_en_i ),
    .E     ( en_i      ),
    .CP    ( clk_i     ),
    .Q     ( clk_o     )
  );
`elsif ULVT
  CKLNQCTD10BWP6T16P96CPDULVT clock_gate_inst (
    .TE    ( test_en_i ),
    .E     ( en_i      ),
    .CP    ( clk_i     ),
    .Q     ( clk_o     )
  );
`endif

endmodule

module tc_clk_inverter (
  input  wire clk_i,
  output wire clk_o
);

`ifdef SVT
  DCCKNCTD6BWP6T16P96CPD clock_inverter_inst (
    .I    ( clk_i ),
    .ZN   ( clk_o )
  );
`elsif LVT
  DCCKNCTD6BWP6T16P96CPDLVT clock_inverter_inst (
    .I    ( clk_i ),
    .ZN   ( clk_o )
  );
`elsif ULVT
  DCCKNCTD6BWP6T16P96CPDULVT clock_inverter_inst (
    .I    ( clk_i ),
    .ZN   ( clk_o )
  );
`endif

endmodule

// Warning: Typical clock mux cells of a technologies std cell library ARE NOT
// GLITCH FREE!! The only difference to a regular multiplexer cell is that they
// feature balanced rise- and fall-times. In other words: SWITCHING FROM ONE
// CLOCK TO THE OTHER CAN INTRODUCE GLITCHES. ALSO, GLITCHES ON THE SELECT LINE
// DIRECTLY TRANSLATE TO GLITCHES ON THE OUTPUT CLOCK!! This cell is only
// intended to be used for quasi-static switching between clocks when one of the
// clocks is anyway inactive or if the downstream wire remains gated or in
// reset state during the transition phase. If you need dynamic switching
// between arbitrary input clocks without introducing glitches, have a look at
// the clk_mux_glitch_free cell in the pulp-platform/common_cells repository.
module tc_clk_mux2 (
  input  wire clk0_i,
  input  wire clk1_i,
  input  wire clk_sel_i,
  output wire clk_o
);

`ifdef SVT
  CKMUX2CTD8BWP6T16P96CPD clock_mux2_inst (
    .I0    ( clk0_i     ),
    .I1    ( clk1_i     ),
    .S     ( clk_sel_i  ),
    .Z     ( clk_o      )
  );
`elsif LVT
  CKMUX2CTD8BWP6T16P96CPDLVT clock_mux2_inst (
    .I0    ( clk0_i     ),
    .I1    ( clk1_i     ),
    .S     ( clk_sel_i  ),
    .Z     ( clk_o      )
  );
`elsif ULVT
  CKMUX2CTD8BWP6T16P96CPDULVT clock_mux2_inst (
    .I0    ( clk0_i     ),
    .I1    ( clk1_i     ),
    .S     ( clk_sel_i  ),
    .Z     ( clk_o      )
  );
`endif

endmodule

module tc_clk_xor2 (
  input  wire clk0_i,
  input  wire clk1_i,
  output wire clk_o
);

`ifdef SVT
  CKXOR2CTD8BWP6T16P96CPD clock_xor2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`elsif LVT
  CKXOR2CTD8BWP6T16P96CPDLVT clock_xor2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`elsif ULVT
  CKXOR2CTD8BWP6T16P96CPDULVT clock_xor2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`endif

endmodule

module tc_clk_or2 (
  input wire clk0_i,
  input wire clk1_i,
  output wire clk_o
);

`ifdef SVT
  CKOR2CTD8BWP6T16P96CPD clock_or2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`elsif LVT
  CKOR2CTD8BWP6T16P96CPDLVT clock_or2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`elsif ULVT
  CKOR2CTD8BWP6T16P96CPDULVT clock_or2_inst (
    .A1   (clk0_i),
    .A2   (clk1_i),
    .Z    (clk_o)
  );
`endif

endmodule

`ifndef SYNTHESIS
module tc_clk_delay #(
  parameter int unsigned Delay = 300ps
) (
  input  wire in_i,
  output wire out_o
);

// pragma translate_off
`ifndef VERILATOR
  assign #(Delay) out_o = in_i;
`endif
// pragma translate_on

endmodule
`endif
