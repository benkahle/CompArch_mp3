module dataMemory(clk, regWE, addr, dataIn, dataOut);
  input clk, regWE;
  input[31:0] addr;
  input[31:0] dataIn;
  output[31:0] dataOut;
  reg[31:0] mem[1023:0];

  always @(posedge clk) begin
    if (regWE) begin
      mem[addr] <= dataIn;
    end
  end
  assign dataOut = mem[addr];
endmodule

module testBench;
  reg clk;
  reg regWE;
  reg[9:0] addr;
  reg[31:0] dataIn;
  wire[31:0] dataOut;
  reg failed;

  dataMemory memTest(clk, regWE, addr, dataIn, dataOut);

  initial begin
    failed = 0;
    clk = 0;
    regWE = 0;
    addr = 0;
    dataIn = 0;

    //test case 1: make sure data not written when regWE = 0
    regWE = 0;
    addr = 10'd1; 
    dataIn = 32'd1;
    #5 clk=1; #5 clk=0;
    if(dataOut == dataIn) begin
      failed = 1;
      $display("dataMemory failure: data present when regWE = 0");
    end

    //test case 2
    regWE = 1;
    addr = 10'd1; 
    dataIn = 32'd1;
    #5 clk=1; #5 clk=0;
    if(dataOut != dataIn) begin
      failed = 1;
      $display("dataMemory failure: data not present or not valid when regWE = 1");
    end

    //test case 3
    regWE = 0;
    addr = 10'd2; 
    #5 clk=1; #5 clk=0;
    if(dataOut != 32'd0) begin
      failed = 1;
      $display("dataMemory failure: data present in empty address");
    end

    if (!failed) $display("dataMemory Passed");
  end
endmodule
