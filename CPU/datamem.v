module datamemory(clk, regWE, Addr, DataIn, DataOut);
 input clk, regWE;
 input[9:0] Addr;
 input[31:0] DataIn;
 output[31:0] DataOut;

reg [31:0] mem[1023:0];
always @(posedge clk)
 if (regWE) mem[Addr] <= DataIn;

assign DataOut = mem[Addr];
endmodule


module datamemorytest();
endmodule