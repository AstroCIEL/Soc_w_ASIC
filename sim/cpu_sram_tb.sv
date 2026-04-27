`timescale 1ns/1ps

module cpu_sram_tb;

  // 时钟 & 复位
  logic clk;
  logic rst_n;

  // DCO 观测口（SIM 下才有）
  logic [5:0] dco_cc_sel_o;
  logic [5:0] dco_fc_sel_o;
  logic [1:0] dco_freq_sel_o;
  logic [2:0] dco_div_sel_o;

  // 其余顶层 IO
  logic clk_led;
  logic tck, tms, tdi;
  logic tdo;
  logic ext_clk;
  logic dco_en;
  logic clk_sel;
  logic div_rst_n;

  // DUT 实例
  soc i_soc (
  `ifdef SIM
    .clk           ( clk            ),
    .dco_cc_sel_o  ( dco_cc_sel_o   ),
    .dco_fc_sel_o  ( dco_fc_sel_o   ),
    .dco_freq_sel_o( dco_freq_sel_o ),
    .dco_div_sel_o ( dco_div_sel_o  ),
  `endif
    .rst_n         ( rst_n          ),
    .clk_led       ( clk_led        ),
    .tck           ( tck            ),
    .tms           ( tms            ),
    .tdi           ( tdi            ),
    .tdo           ( tdo            ),
    .ext_clk       ( ext_clk        ),
    .dco_en        ( dco_en         ),
    .clk_sel       ( clk_sel        ),
    .div_rst_n     ( div_rst_n      )
  );

  // 50 MHz 时钟
  initial clk = 1'b0;
  always #10 clk = ~clk;

  initial begin
    $fsdbDumpfile("cpu_sram_tb.fsdb");
    $fsdbDumpvars(0, cpu_sram_tb);
  end

  // 其他 IO 默认拉成安全值
  initial begin
    tck       = 1'b0;
    tms       = 1'b0;
    tdi       = 1'b0;
    ext_clk   = 1'b0;
    dco_en    = 1'b0;
    clk_sel   = 1'b0;
    div_rst_n = 1'b1;
  end

  // 复位流程
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;

    #20;
    // 指令+数据均在 SRAM：将 test_sram.hex 载入 主存SRAM 低地址，CPU 从 SRAM 取指；数据放在sram_1024_64_lx
    //makefile里面有SIM,用的是tc_sram.sv，存储是sram[1023:0]  每个元素64bit？
    // $display("[TB] Loading test_sram.hex into main mem...");
    // $readmemh("../../CPU_C_code/test_sram.hex", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram);
    // $display("[TB] Load done.");

  end


  // 监视 ERROR_FLAG_ADDR = 0x8000_1000 （word index = 512）
  localparam int ERROR_WORD_INDEX = 512;

  initial begin
    logic [63:0]  error_flag_word;

    // 等程序运行一段时间（可视需要调整）
    repeat (500000) @(posedge clk);

    error_flag_word = i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[ERROR_WORD_INDEX];

    $display("[TB] error_flag_word = 0x%016h", error_flag_word);
    // $display("[TB] sram[0]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[0]);
    // $display("[TB] sram[1]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[1]);
    // $display("[TB] sram[2]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[2]);
    // $display("[TB] sram[3]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[3]);
    // $display("[TB] sram[4]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[4]);
    // $display("[TB] sram[5]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[5]);
    // $display("[TB] sram[6]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[6]);
    // $display("[TB] sram[7]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[7]);
    // $display("[TB] sram[8]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[8]);
    // $display("[TB] sram[9]  = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[9]);
    // $display("[TB] sram[10] = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[10]);
    // $display("[TB] sram[11] = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[11]);
    // $display("[TB] sram[12] = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[12]);
    // $display("[TB] sram[13] = 0x%016h", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[13]);
   
    // $display("[TB] sram_1024_64_lx[0] = 0x%016h", i_soc.i_sram_1024_64_wrapper.gen_main_mem[0].main_mem_inst.mem[0]);
    // $display("[TB] sram_1024_64_lx[1] = 0x%016h", i_soc.i_sram_1024_64_wrapper.gen_main_mem[0].main_mem_inst.mem[1]);
    // $display("[TB] sram_1024_64_lx[2] = 0x%016h", i_soc.i_sram_1024_64_wrapper.gen_main_mem[0].main_mem_inst.mem[2]);
    // $display("[TB] sram_1024_64_lx[3] = 0x%016h", i_soc.i_sram_1024_64_wrapper.gen_main_mem[0].main_mem_inst.mem[3]);
    // $display("[TB] sram_1024_64_lx[4] = 0x%016h", i_soc.i_sram_1024_64_wrapper.gen_main_mem[0].main_mem_inst.mem[4]);
    


    if (error_flag_word == 64'h1234567812345678) begin
      $display("[TB] SRAM TEST PASS.");
    end else if (error_flag_word == 64'hDEADBEEFDEADBEEF) begin
      $display("[TB] SRAM TEST FAIL (flag set).");
    end else begin
      $display("[TB] SRAM TEST UNKNOWN (flag not set to expected values).");
    end

    $finish;
  end

endmodule
