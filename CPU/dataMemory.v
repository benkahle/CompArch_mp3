module dataMemory(clk, regWrEn, addr, dataIn, dataOut);
  input clk, regWrEn;
  input[31:0] addr;
  input[31:0] dataIn;
  output[31:0] dataOut;
  reg[31:0] mem[1023:0];

  always @(posedge clk) begin
    if (regWrEn) begin
      mem[addr] <= dataIn;
    end
  end
  assign dataOut = mem[addr];
endmodule

module testBench;
  reg clk;
  reg regWrEn;
  reg[9:0] addr;
  reg[31:0] dataIn;
  wire[31:0] dataOut;
  reg failed;

  dataMemory memTest(clk, regWrEn, addr, dataIn, dataOut);

  initial begin
    failed = 0;
    clk = 0;
    regWrEn = 0;
    addr = 0;
    dataIn = 0;

    //test case 1: make sure data not written when regWrEn = 0
    regWrEn = 0;
    addr = 10'd1; 
    dataIn = 32'd1;
    #5 clk=1; #5 clk=0;
    if(dataOut == dataIn) begin
      failed = 1;
      $display("dataMemory failure: data present when regWrEn = 0");
    end

    //test case 2
    regWrEn = 1;
    addr = 10'd1; 
    dataIn = 32'd1;
    #5 clk=1; #5 clk=0;
    if(dataOut != dataIn) begin
      failed = 1;
      $display("dataMemory failure: data not present or not valid when regWrEn = 1");
    end

    //test case 3
    regWrEn = 0;
    addr = 10'd2; 
    #5 clk=1; #5 clk=0;
    if(dataOut != 32'd0) begin
      failed = 1;
      $display("dataMemory failure: data present in empty address");
    end

    if (!failed) $display("dataMemory Passed");
  end
endmodule
