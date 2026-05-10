// VMMA (VecMatMul) accelerator — simulation model with internal DMA.
// Register map aligned with ASIC_INTEGRATION.md (64-bit AXI cfg slots).
// Supports dtype INT16 only (CTRL[1:0] == 2'b01); M,N <= 32.
// Writes Y as one INCR burst (packed int16) to avoid repeated sub-word writes.

module vmma_top (
    input  logic       clk_i,
    input  logic       rst_ni,
    AXI_BUS.Slave      cfg,
    AXI_BUS.Master     mst,
    output logic       irq_o
);

  localparam int unsigned MAXMN = 32;

  localparam logic [11:0] REG_CMD        = 12'h000;
  localparam logic [11:0] REG_STATUS     = 12'h008;
  localparam logic [11:0] REG_CTRL       = 12'h010;
  localparam logic [11:0] REG_M_DIM      = 12'h018;
  localparam logic [11:0] REG_N_DIM      = 12'h020;
  localparam logic [11:0] REG_W_ADDR     = 12'h028;
  localparam logic [11:0] REG_X_ADDR     = 12'h030;
  localparam logic [11:0] REG_Y_ADDR     = 12'h038;
  localparam logic [11:0] REG_W_STRIDE   = 12'h040;
  localparam logic [11:0] REG_CYCLE_CNT  = 12'h048;
  localparam logic [11:0] REG_IRQ_MASK   = 12'h050;
  localparam logic [11:0] REG_IRQ_STAT   = 12'h058;

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_X_AR,
    ST_X_R,
    ST_W_AR,
    ST_W_R,
    ST_COMP,
    ST_YWBURST_AW,
    ST_YWBURST_W,
    ST_YWBURST_B,
    ST_FINISH
  } st_t;

  logic        cfg_req, cfg_we;
  logic [63:0] cfg_addr, cfg_wdata, cfg_rdata, cfg_rdata_q;

  logic [63:0] w_addr_q, x_addr_q, y_addr_q, stride_q, cycle_cnt_q;
  logic [31:0] m_q, n_q, ctrl_q;
  logic        busy_q, done_q, irq_mask_q, irq_status_q;
  logic [3:0]  err_q;

  st_t         st_q;
  logic [31:0] row_q;
  logic [31:0] beat_q;
  logic [31:0] x_beats_q, w_beats_q;
  logic [31:0] y_out_beats_q;

  logic signed [15:0] x_mem [0:MAXMN-1];
  logic signed [15:0] w_mem [0:MAXMN-1];
  logic        [15:0] y_lat_q [0:MAXMN-1];
  logic signed [47:0] dot_q;

  axi2mem #(
      .AXI_ID_WIDTH   ( $bits(cfg.aw_id) ),
      .AXI_ADDR_WIDTH ( 64 ),
      .AXI_DATA_WIDTH ( 64 ),
      .AXI_USER_WIDTH ( 1 )
  ) i_cfg_axi2mem (
      .clk_i  ( clk_i ),
      .rst_ni ( rst_ni ),
      .slave  ( cfg ),
      .req_o  ( cfg_req ),
      .we_o   ( cfg_we ),
      .addr_o ( cfg_addr ),
      .be_o   ( ),
      .user_o ( ),
      .data_o ( cfg_wdata ),
      .user_i ( '0 ),
      .data_i ( cfg_rdata )
  );

  always_comb begin
    dot_q = 48'sd0;
    for (int i = 0; i < MAXMN; i++) begin
      if (i < n_q) dot_q = dot_q + 48'($signed(w_mem[i]) * $signed(x_mem[i]));
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      w_addr_q     <= '0;
      x_addr_q     <= '0;
      y_addr_q     <= '0;
      stride_q     <= '0;
      m_q          <= '0;
      n_q          <= '0;
      ctrl_q       <= '0;
      cycle_cnt_q  <= '0;
      cfg_rdata_q  <= '0;
      busy_q       <= 1'b0;
      done_q       <= 1'b0;
      err_q        <= '0;
      irq_mask_q   <= 1'b0;
      irq_status_q <= 1'b0;
      st_q         <= ST_IDLE;
      row_q        <= '0;
      beat_q       <= '0;
      x_beats_q    <= '0;
      w_beats_q    <= '0;
      y_out_beats_q <= '0;
    end else begin
      if (cfg_req) begin
        if (cfg_we) begin
          unique case (cfg_addr[11:0])
            REG_CMD: begin
              if (cfg_wdata[1]) begin
                done_q       <= 1'b0;
                irq_status_q <= 1'b0;
                err_q        <= '0;
              end
            end
            REG_CTRL:       ctrl_q       <= cfg_wdata[31:0];
            REG_M_DIM:      m_q          <= cfg_wdata[31:0];
            REG_N_DIM:      n_q          <= cfg_wdata[31:0];
            REG_W_ADDR:     w_addr_q     <= cfg_wdata;
            REG_X_ADDR:     x_addr_q     <= cfg_wdata;
            REG_Y_ADDR:     y_addr_q     <= cfg_wdata;
            REG_W_STRIDE:   stride_q     <= cfg_wdata;
            REG_IRQ_MASK:   irq_mask_q   <= cfg_wdata[0];
            REG_IRQ_STAT:   if (cfg_wdata[0]) irq_status_q <= 1'b0;
            default: ;
          endcase
        end else begin
          unique case (cfg_addr[11:0])
            REG_STATUS:    cfg_rdata_q <= {56'b0, err_q[3:0], 2'b0, done_q, busy_q};
            REG_CTRL:      cfg_rdata_q <= {32'b0, ctrl_q};
            REG_M_DIM:     cfg_rdata_q <= {32'b0, m_q};
            REG_N_DIM:     cfg_rdata_q <= {32'b0, n_q};
            REG_W_ADDR:    cfg_rdata_q <= w_addr_q;
            REG_X_ADDR:    cfg_rdata_q <= x_addr_q;
            REG_Y_ADDR:    cfg_rdata_q <= y_addr_q;
            REG_W_STRIDE:  cfg_rdata_q <= stride_q;
            REG_CYCLE_CNT: cfg_rdata_q <= cycle_cnt_q;
            REG_IRQ_MASK:  cfg_rdata_q <= {63'b0, irq_mask_q};
            REG_IRQ_STAT:  cfg_rdata_q <= {63'b0, irq_status_q};
            default:       cfg_rdata_q <= 64'h0;
          endcase
        end
      end

      if (busy_q) cycle_cnt_q <= cycle_cnt_q + 64'd1;

      unique case (st_q)
        ST_IDLE: begin
          if (cfg_req && cfg_we && (cfg_addr[11:0] == REG_CMD) && cfg_wdata[0] && !busy_q) begin
            if (ctrl_q[1:0] != 2'b01 || m_q == 0 || n_q == 0 || m_q > MAXMN || n_q > MAXMN) begin
              err_q        <= 4'd1;
              done_q       <= 1'b1;
              irq_status_q <= 1'b1;
              busy_q       <= 1'b0;
            end else begin
              busy_q       <= 1'b1;
              done_q       <= 1'b0;
              err_q        <= '0;
              cycle_cnt_q  <= '0;
              row_q        <= '0;
              beat_q       <= '0;
              x_beats_q    <= (2 * n_q + 7) >> 3;
              w_beats_q    <= (2 * n_q + 7) >> 3;
              st_q         <= ST_X_AR;
            end
          end
        end
        ST_X_AR: begin
          if (mst.ar_ready) begin
            beat_q <= '0;
            st_q   <= ST_X_R;
          end
        end
        ST_X_R: begin
          if (mst.r_valid) begin
            for (int k = 0; k < 4; k++) begin
              automatic int idx = beat_q * 4 + k;
              if (idx < n_q) x_mem[idx] <= $signed(mst.r_data[16*k +: 16]);
            end
            if (mst.r_last) begin
              beat_q <= '0;
              st_q   <= ST_W_AR;
            end else beat_q <= beat_q + 1;
          end
        end
        ST_W_AR: begin
          if (mst.ar_ready) begin
            beat_q <= '0;
            st_q   <= ST_W_R;
          end
        end
        ST_W_R: begin
          if (mst.r_valid) begin
            for (int k = 0; k < 4; k++) begin
              automatic int idx = beat_q * 4 + k;
              if (idx < n_q) w_mem[idx] <= $signed(mst.r_data[16*k +: 16]);
            end
            if (mst.r_last) st_q <= ST_COMP;
            else beat_q <= beat_q + 1;
          end
        end
        ST_COMP: begin
          y_lat_q[row_q] <= dot_q[15:0];
          if (row_q + 1 >= m_q) begin
            y_out_beats_q <= (2 * m_q + 7) >> 3;
            beat_q        <= '0;
            st_q          <= ST_YWBURST_AW;
          end else begin
            row_q  <= row_q + 1;
            beat_q <= '0;
            st_q   <= ST_W_AR;
          end
        end
        ST_YWBURST_AW: begin
          if (mst.aw_ready) st_q <= ST_YWBURST_W;
        end
        ST_YWBURST_W: begin
          if (mst.w_ready) begin
            if (beat_q + 1 >= y_out_beats_q) st_q <= ST_YWBURST_B;
            else beat_q <= beat_q + 1;
          end
        end
        ST_YWBURST_B: begin
          if (mst.b_valid) st_q <= ST_FINISH;
        end
        ST_FINISH: begin
          busy_q       <= 1'b0;
          done_q       <= 1'b1;
          irq_status_q <= 1'b1;
          st_q         <= ST_IDLE;
        end
        default: st_q <= ST_IDLE;
      endcase
    end
  end

  assign cfg_rdata = cfg_rdata_q;

  assign mst.aw_lock   = '0;
  assign mst.aw_cache  = '0;
  assign mst.aw_prot   = '0;
  assign mst.aw_atop   = '0;
  assign mst.aw_region = '0;
  assign mst.aw_user   = '0;
  assign mst.aw_qos    = '0;
  assign mst.w_user    = '0;
  assign mst.ar_id     = '0;
  assign mst.ar_lock   = '0;
  assign mst.ar_cache  = '0;
  assign mst.ar_prot   = '0;
  assign mst.ar_region = '0;
  assign mst.ar_user   = '0;
  assign mst.ar_qos    = '0;

  logic [63:0] ar_addr_val;
  logic [7:0]  ar_len_val;
  logic [63:0] aw_addr_val;
  logic [63:0] w_data_val;
  logic [7:0]  w_strb_val;
  logic        w_last_val;

  always_comb begin
    ar_addr_val = x_addr_q;
    ar_len_val  = x_beats_q[7:0] - 8'd1;
    if (st_q == ST_W_AR || st_q == ST_W_R) begin
      ar_addr_val = w_addr_q + row_q * stride_q;
      ar_len_val  = w_beats_q[7:0] - 8'd1;
    end

    aw_addr_val = { y_addr_q[63:3], 3'b000 };
    w_data_val  = '0;
    w_strb_val  = '0;
    w_last_val  = 1'b0;
    if (st_q == ST_YWBURST_W) begin
      for (int k = 0; k < 4; k++) begin
        automatic int e = beat_q * 4 + k;
        if (e < m_q) begin
          w_data_val[16*k +: 16] = y_lat_q[e];
          w_strb_val[2*k +: 2]   = 2'b11;
        end
      end
      w_last_val = (beat_q + 1 >= y_out_beats_q);
    end
  end

  assign mst.ar_addr   = ar_addr_val;
  assign mst.ar_len    = ar_len_val;
  assign mst.ar_size   = 3'b011;
  assign mst.ar_burst  = 2'b01;
  assign mst.ar_valid  = (st_q == ST_X_AR) || (st_q == ST_W_AR);

  assign mst.r_ready   = (st_q == ST_X_R) || (st_q == ST_W_R);

  assign mst.aw_addr   = aw_addr_val;
  assign mst.aw_len    = (st_q == ST_YWBURST_AW || st_q == ST_YWBURST_W || st_q == ST_YWBURST_B)
                         ? y_out_beats_q[7:0] - 8'd1 : 8'd0;
  assign mst.aw_size   = 3'b011;
  assign mst.aw_burst  = 2'b01;
  assign mst.aw_valid  = (st_q == ST_YWBURST_AW);

  assign mst.w_data    = w_data_val;
  assign mst.w_strb    = w_strb_val;
  assign mst.w_last    = w_last_val;
  assign mst.w_valid   = (st_q == ST_YWBURST_W);

  assign mst.b_ready   = (st_q == ST_YWBURST_B);

  assign mst.aw_id     = '0;

  assign irq_o = irq_mask_q & irq_status_q;

endmodule
