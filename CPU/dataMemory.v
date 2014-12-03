module dataMemory(clk, regWE, addr, dataIn, dataOut);
  input clk, regWE;
  input[9:0] addr;
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
module testBenchHarness;
  wire clk, regWE;
  wire[9:0] addr;
  wire[31:0] dataIn;
  wire[31:0] dataOut;
  reg beginTest;

  dataMemory memTest(clk, regWE, addr, dataIn, dataOut);
  testBench test(clk, beginTest, regWE, addr, dataIn, dataOut);

  initial begin
    beginTest = 0;
    #10;
    beginTest = 1;
    #300;
  end
endmodule
module testBench(clk, beginTest, regWE, addr, dataIn, dataOut);
  output reg clk;
  output reg regWE;
  output reg[9:0] addr;
  output reg[31:0] dataIn;
  input[31:0] dataOut;
  input beginTest;

  initial begin
    clk = 0;
    regWE = 0;
    addr = 0;
    dataIn = 0;
  end
  always @(posedge beginTest) begin
    #10;
    
    //test case 1: make sure data not written when regWE = 0
    #5 clk=1; #5 clk=0;
    regWE = 0;
    addr = 10'd1; 
    dataIn = 32'd1;
    if(dataOut == dataIn) begin
      $display("dataMemory failure: data present when regWE = 0");
    end

    //#100;

    //test case 2
    #5 clk=1; #5 clk=0;
    regWE = 1;
    addr = 10'd1; 
    dataIn = 32'd1;
    if(dataOut != dataIn) begin
      $display("dataMemory failure: data not present when regWE = 1");
    end

    //#100

    //test case 3
    #5 clk=1; #5 clk=0;
    regWE = 1;
    addr = 10'd1; 
    dataIn = 32'd1;
    if(dataOut == dataIn[10'd0]) begin
      $display("dataMemory failure: data present in empty address");
    end
  end
endmodule
