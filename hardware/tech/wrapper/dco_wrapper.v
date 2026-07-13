// DCO wrapper: configuration input registers + DCO macro instance.
//
// Configuration inputs are wired directly from the SoC top level (no AXI / scan
// chain).  They are registered on ext_clk_i before driving the DCO control pins.
//
// DIV_SEL and FREQ_SEL share the same top-level freq_sel input to reduce GPIO.
// CLK_DIV from the DCO macro is further divided by 32 before leaving the wrapper.
//
// The underlying `DCO` module is selected by the technology filelist:
//   sim  -> hardware/tech/sim/DCO.v   (behavioral)
//   syn  -> hardware/tech/syn/DCO.v   (post-PnR netlist)
//
// On reset the configuration registers load safe-boot defaults so the DCO can
// start oscillating before external pins are driven.

module dco_wrapper #(
  parameter logic        SafeBootEn     = 1'b1,
  parameter logic        SafeBootClkSel = 1'b0,
  parameter logic [5:0]  SafeBootCcSel  = 6'd16,
  parameter logic [5:0]  SafeBootFcSel  = 6'd0,
  parameter logic [1:0]  SafeBootFreqSel= 2'b00
) (
  input  logic       ext_clk_i,
  input  logic       rst_ni,
  input  logic       en_i,
  input  logic [5:0] cc_sel_i,
  input  logic [5:0] fc_sel_i,
  input  logic       clk_sel_i,
  input  logic [1:0] freq_sel_i,
  output logic       clk_o,
  output logic       clk_div_o
);

  logic       dco_clk_div;
  logic [4:0] clk_div32_cnt;

  logic       en_q;
  logic [5:0] cc_sel_q;
  logic [5:0] fc_sel_q;
  logic       clk_sel_q;
  logic [1:0] freq_sel_q;

  always @(posedge ext_clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      en_q       <= SafeBootEn;
      cc_sel_q   <= SafeBootCcSel;
      fc_sel_q   <= SafeBootFcSel;
      clk_sel_q  <= SafeBootClkSel;
      freq_sel_q <= SafeBootFreqSel;
    end else begin
      en_q       <= en_i;
      cc_sel_q   <= cc_sel_i;
      fc_sel_q   <= fc_sel_i;
      clk_sel_q  <= clk_sel_i;
      freq_sel_q <= freq_sel_i;
    end
  end

  DCO i_dco (
    .EN       (en_q       ),
    .CC_SEL   (cc_sel_q   ),
    .FC_SEL   (fc_sel_q   ),
    .EXT_CLK  (ext_clk_i  ),
    .CLK_SEL  (clk_sel_q  ),
    .DIV_SEL  (freq_sel_q ),
    .FREQ_SEL (freq_sel_q ),
    .CLK      (clk_o       ),
    .CLK_DIV  (dco_clk_div ),
    .RSTN     (rst_ni      )
  );

  // Observation clock: divide DCO CLK_DIV by 32 for easier pad probing.
  always_ff @(posedge dco_clk_div or negedge rst_ni) begin
    if (!rst_ni) begin
      clk_div32_cnt <= 5'b0;
    end else begin
      clk_div32_cnt <= clk_div32_cnt + 5'd1;
    end
  end

  assign clk_div_o = clk_div32_cnt[4];

endmodule
