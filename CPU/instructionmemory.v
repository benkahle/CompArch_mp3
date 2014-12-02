module instructionmemory(clk, Addr, DataOut);
 input clk, regWE;
 input[9:0] Addr;
 input[31:0] DataIn;
 output[31:0] DataOut;

reg [31:0] mem[1023:0];
always @(posedge clk)
  initial $readmemh(“hexcode.dat”, mem);
  assign DataOut = mem[Addr];
endmodule

module instructionmemorytest();
endmodule
