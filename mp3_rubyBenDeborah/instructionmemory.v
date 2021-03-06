module instructionMemory(clk, addr, dataOut);
  input clk;
  input[31:0] addr;
  output reg[31:0] dataOut;
  reg [31:0] mem[1023:0];
  //initial $readmemh("hexdata.dat", mem);
  always @(addr) begin
    dataOut = mem[addr/4];
  end
endmodule

module testBench;
  reg clk;
  reg[31:0] addr;
  wire[31:0] dataOut;
  reg failed;
  reg [31:0] commands[42:0]; //We have 43 commands in our assembly
  reg [5:0] i;

  instructionMemory memTest(clk, addr, dataOut);
  //initial $readmemh("hexcode.dat", commands);
  initial begin
    failed = 0;
    clk = 0;
    addr = 0;
    i = 0;

    for (i=0; i<42; i=i+1) begin
      addr = addr+i*4;
      clk=1;clk=0;
      $display("expected command at %d: %h", addr, commands[i]);
      if (dataOut != commands[i]) begin
        failed = 1;
        $display("instructionMemory failure: memory %h at address %d does not match expected command %h", dataOut, addr, commands[i]);
      end
    end

    if (!failed) $display("instructionMemory Passed");
  end

endmodule