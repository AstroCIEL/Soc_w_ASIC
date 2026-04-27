`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Testbench for sram_1024_64_wrapper: 验证 wrapper 将 sram_1024_64_lx 正确接到
// axi2mem 风格接口（req, we, addr, be, wdata, rdata）上，读写一致。
//////////////////////////////////////////////////////////////////////////////////

module test_sram_wrapper_tb;

  localparam int AXI_ADDR_WIDTH = 64;
  localparam int AXI_DATA_WIDTH = 64;

  logic                  clk;
  logic                  rstn;
  logic                  axi_req;
  logic                  axi_we;
  logic [AXI_ADDR_WIDTH-1:0] axi_addr;
  logic [AXI_DATA_WIDTH/8-1:0] axi_be; //根本没用，不用赋值也行吧
  logic [AXI_DATA_WIDTH-1:0] axi_wdata;
  logic [AXI_DATA_WIDTH-1:0] axi_rdata;

  // 时钟
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // DUT
  sram_1024_64_wrapper #(
    .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH   ),
    .AXI_DATA_WIDTH    ( AXI_DATA_WIDTH   ),
    .AXI_ADDR_OFFSET   ( 3               ),
    .NUM_MACROS        ( 1               ),
    .MACRO_ADDR_WIDTH  ( 10              )
  ) i_wrapper (
    .clk_i             ( clk             ),
    .rstn_i            ( rstn            ),
    .axi_req_i         ( axi_req         ),
    .axi_write_en_i    ( axi_we          ),
    .axi_addr_i        ( axi_addr         ),
    .axi_byte_en_i     ( axi_be          ),
    .axi_wdata_i       ( axi_wdata       ),
    .axi_rdata_o       ( axi_rdata       )
  );

  initial begin
    $fsdbDumpfile("test_sram_wrapper_tb.fsdb");
    $fsdbDumpvars(0, test_sram_wrapper_tb);
  end

  // 复位
  initial begin
    rstn = 1'b0;
    axi_req = 1'b0;
    axi_we  = 1'b0;
    axi_addr  = '0;
    axi_be    = '1;
    axi_wdata = '0;
    repeat (5) @(posedge clk);
    rstn = 1'b1;
    repeat (2) @(posedge clk);
  end

  // 写一个字：addr 为 64-bit 字地址（即 byte_addr = addr << 3）
  task automatic write_word(input logic [AXI_ADDR_WIDTH-1:0] word_addr, input logic [AXI_DATA_WIDTH-1:0] data);
    @(posedge clk);
    axi_req   = 1'b1;
    axi_we    = 1'b1;
    axi_addr  = word_addr << 3;  // wrapper 取 addr[12:3] 为 word index
    axi_be    = '1;
    axi_wdata = data;
    @(posedge clk);
    axi_req   = 1'b0;
    axi_we    = 1'b0;
    @(posedge clk);
  endtask

  // 读一个字：发 req 后等 2 拍再采样 rdata
  //关键是不知道AXI是怎么读SRAM的？什么时候认为数据有效的？
  task automatic read_word(input logic [AXI_ADDR_WIDTH-1:0] word_addr, output logic [AXI_DATA_WIDTH-1:0] data);
    @(posedge clk);
    axi_req   = 1'b1;
    axi_we    = 1'b0;
    axi_addr  = word_addr << 3;
    axi_be    = '1;
    @(posedge clk);
    axi_req   = 1'b0;
    @(posedge clk);  // 再等一拍，rdata 对齐到当前读地址
    data      = axi_rdata;
    // @(posedge clk);
  endtask

  // 主测试流程
  initial begin
    logic [AXI_DATA_WIDTH-1:0] rd;
    int err = 0;
    wait (rstn === 1'b1);
    repeat (3) @(posedge clk);

    $display("[TB] === sram_1024_64_wrapper test start ===");

    // 写若干地址
    write_word(64'd0,   64'h0123_4567_89ab_cdef);
    write_word(64'd1,   64'hdead_beef_dead_beef);
    write_word(64'd2,   64'h0000_0000_0000_0001);
    write_word(64'd511, 64'h8000_0000_8000_0000);
    write_word(64'd1023,64'hffff_ffff_ffff_ffff);

    repeat (2) @(posedge clk);

    // 读回并校验
    read_word(64'd0, rd);
    if (rd !== 64'h0123_4567_89ab_cdef) begin
      $display("[TB] FAIL: addr 0 expect 0x0123_4567_89ab_cdef, got 0x%016h", rd);
      err++;
    end else
      $display("[TB] OK: addr 0 = 0x%016h", rd);
    @(posedge clk);

    read_word(64'd1, rd);
    if (rd !== 64'hdead_beef_dead_beef) begin
      $display("[TB] FAIL: addr 1 expect 0xdead_beef_dead_beef, got 0x%016h", rd);
      err++;
    end else
      $display("[TB] OK: addr 1 = 0x%016h", rd);
    @(posedge clk);
    
    read_word(64'd2, rd);
    if (rd !== 64'h0000_0000_0000_0001) begin
      $display("[TB] FAIL: addr 2 expect 0x0000_0000_0000_0001, got 0x%016h", rd);
      err++;
    end else
      $display("[TB] OK: addr 2 = 0x%016h", rd);
    @(posedge clk);

    read_word(64'd511, rd);
    if (rd !== 64'h8000_0000_8000_0000) begin
      $display("[TB] FAIL: addr 511 expect 0x8000_0000_8000_0000, got 0x%016h", rd);
      err++;
    end else
      $display("[TB] OK: addr 511 = 0x%016h", rd);
    @(posedge clk);

    read_word(64'd1023, rd);
    if (rd !== 64'hffff_ffff_ffff_ffff) begin
      $display("[TB] FAIL: addr 1023 expect 0xffff_ffff_ffff_ffff, got 0x%016h", rd);
      err++;
    end else
      $display("[TB] OK: addr 1023 = 0x%016h", rd);
    @(posedge clk);

    if (err == 0)
      $display("[TB] === SRAM WRAPPER TEST PASS ===");
    else
      $display("[TB] === SRAM WRAPPER TEST FAIL (%0d errors) ===", err);
    $fsdbDumpflush;
    $finish;
  end

endmodule
