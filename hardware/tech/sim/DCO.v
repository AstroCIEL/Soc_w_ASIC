// Behavioral simulation model for the DCO.
// Interface and functional behavior match the gate-level implementation in
// hardware/tech/syn/DCO.v, but standard cells are replaced with synthesizable-
// agnostic behavioral logic for faster functional simulation.

`timescale 1ps / 1ps

module DCO_RING #(
  parameter real BASE_HALF_PERIOD_PS = 500.0,
  parameter real BUF_DELAY_PS        = 25.0,
  parameter real CAP_DELAY_PS        = 5.0
) (
  input  wire       EN,
  input  wire [5:0] SEL,
  input  wire [5:0] FC_SEL,
  output wire       DCLK
);

  real half_period_ps;
  reg  dclk_reg;

  function automatic real calc_half_period_ps(
    input [5:0] sel,
    input [5:0] fc_sel
  );
    real coarse_delay;
    real fine_delay;
    begin
      coarse_delay = 0.0;
      if (sel[0]) coarse_delay = coarse_delay + 1.0;
      if (sel[1]) coarse_delay = coarse_delay + 1.0;
      if (sel[2]) coarse_delay = coarse_delay + 2.0;
      if (sel[3]) coarse_delay = coarse_delay + 4.0;
      if (sel[4]) coarse_delay = coarse_delay + 8.0;
      if (sel[5]) coarse_delay = coarse_delay + 16.0;

      // VARIABLE_CAP instance counts per FC_SEL bit in the netlist.
      fine_delay = fc_sel[0] * 1.0
                 + fc_sel[1] * 2.0
                 + fc_sel[2] * 3.0
                 + fc_sel[3] * 4.0
                 + fc_sel[4] * 5.0
                 + fc_sel[5] * 6.0;

      calc_half_period_ps = BASE_HALF_PERIOD_PS
                          + coarse_delay * BUF_DELAY_PS
                          + fine_delay   * CAP_DELAY_PS;
    end
  endfunction

  always @(*) begin
    half_period_ps = calc_half_period_ps(SEL, FC_SEL);
  end

  assign DCLK = dclk_reg;

  initial begin
    dclk_reg = 1'b0;
  end

  always begin
    dclk_reg = 1'b0;
    forever begin
      wait (EN === 1'b1);
      while (EN === 1'b1) begin
        #(half_period_ps);
        if (EN !== 1'b1) begin
          dclk_reg = 1'b0;
          break;
        end
        dclk_reg = ~dclk_reg;
      end
    end
  end

endmodule


// Simulation-friendly programmable divider.
// SEL==0 passes CLK_IN through (safe-boot default). Other values toggle
// at CLK_IN divided by 2^(SEL).
module MX_CLK_DIVIDER (
  input  wire       CLK_IN,
  input  wire [1:0] SEL,
  input  wire       FRSTN,
  output wire       CLK_OUT
);

  reg [2:0] cnt_q;

  always @(posedge CLK_IN or negedge FRSTN) begin
    if (!FRSTN) begin
      cnt_q <= 3'b0;
    end else begin
      cnt_q <= cnt_q + 3'd1;
    end
  end

  assign CLK_OUT = (SEL == 2'b00) ? CLK_IN :
                   (SEL == 2'b01) ? cnt_q[0] :
                   (SEL == 2'b10) ? cnt_q[1] :
                                    cnt_q[2];

endmodule


module DCO (
  input  wire       EN,
  input  wire [5:0] CC_SEL,
  input  wire [5:0] FC_SEL,
  input  wire       EXT_CLK,
  input  wire       CLK_SEL,
  input  wire [1:0] DIV_SEL,
  input  wire [1:0] FREQ_SEL,
  output wire       CLK,
  output wire       CLK_DIV,
  input  wire       RSTN
);

  wire       ring_out;
  wire       clk_select;
  wire       div_clk_out;
  wire       clk_i;

  DCO_RING #(
    .BASE_HALF_PERIOD_PS (500.0),
    .BUF_DELAY_PS        (25.0),
    .CAP_DELAY_PS        (5.0)
  ) dco_core (
    .EN     (EN),
    .SEL    (CC_SEL),
    .FC_SEL (FC_SEL),
    .DCLK   (ring_out)
  );

  assign clk_select = CLK_SEL ? EXT_CLK : ring_out;

  MX_CLK_DIVIDER divider_test (
    .CLK_IN  (clk_select),
    .CLK_OUT (div_clk_out),
    .SEL     (DIV_SEL),
    .FRSTN   (RSTN)
  );

  MX_CLK_DIVIDER divider_clk (
    .CLK_IN  (clk_select),
    .CLK_OUT (clk_i),
    .SEL     (FREQ_SEL),
    .FRSTN   (RSTN)
  );

  assign CLK     = clk_i;
  assign CLK_DIV = div_clk_out;

endmodule
