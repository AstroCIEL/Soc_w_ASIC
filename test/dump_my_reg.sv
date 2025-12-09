module dump();
initial begin
  $dumpfile("waveforms/my_reg.vcd");
  $dumpvars(0, my_reg); 
end
endmodule