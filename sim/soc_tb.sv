module soc_tb;

	logic clk, rst_n;

	initial begin

		$fsdbDumpfile("waveform.fsdb");
		$fsdbDumpvars("+all");
		$fsdbDumpMDA();

		clk = 1;
		rst_n = 0;
		

		#20
		rst_n = 1;
		
		#20000
		$finish;
	end
	
	always #5 clk = ~clk;


	soc i_soc
	(
		.clk	(clk),
		.rst_n (rst_n)
	);

`ifdef SIM
  initial begin
    $display("SIM is defined");
	end
`else
  initial begin
    $display("SIM is not defined");
  end
`endif

endmodule
