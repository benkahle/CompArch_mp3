/////////////////////////
// Ruby
// register file
// specs:
//	width: 32 bit
//	depth: 32 word
//	WP: synchronous, + edge triggered
//	RP1: asynchronous
//	RP2: asynchronous
/////////////////////////

module register32(q, d, wrenable, clk);
  input[31:0] d;
  input wrenable;
  input clk;
  output reg[31:0] q;

  always @(posedge clk) begin
    if(wrenable) begin
      q = d;
    end
  end

endmodule
module register32zero(q, d, wrenable, clk);
  input[31:0] d;
  input wrenable;
  input clk;
  output reg [31:0] q;

  always @(posedge clk) begin
    q = 32'b0;
  end
endmodule
module mux32to1by32(out, address, inputs);
  input[31:0] inputs[31:0];
  input[4:0] address;
  output[31:0] out;

  assign out = inputs[address]; // Connects the output of the array
endmodule
module decoder1to32(out, enable, address);
  output[31:0] out;
  input enable;
  input[4:0] address;
 
  assign out = enable<<address; 
endmodule
module regfile(ReadData1, // Contents of first register read
 		ReadData2, // Contents of second register read
 		WriteData, // Contents to write to register
 		ReadRegister1, // Address of first register to read 
 		ReadRegister2, // Address of second register to read
		WriteRegister, // Address of register to write
 		RegWrite, // Enable writing of register when High
 		Clk); // Clock (Positive Edge Triggered)
  output[31:0]	ReadData1;
  output[31:0]	ReadData2;
  input[31:0]	WriteData;
  input[4:0]	ReadRegister1;
  input[4:0]	ReadRegister2;
  input[4:0]	WriteRegister;
  input		RegWrite;
  input		Clk;

  wire		WriteEnable;
  wire [31:0]	Q[31:0];	

  decoder1to32 decode(WriteEnable, RegWrite, WriteRegister);
  genvar i;
  generate (i; i<32; i++) begin;
    register32 register(Q[i], WriteData, WriteEnable, Clk);
  end
   
  mux32to1by32 mux1(ReadData1, ReadRegister1, Q);
  mux32to1by32 mux2(ReadData2, ReadRegister2, Q);

  //assign ReadData1 = 42;
  //assign ReadData2 = 42;
endmodule
module hw4testbenchharness;
  wire[31:0]	ReadData1;
  wire[31:0]	ReadData2;
  wire[31:0]	WriteData;
  wire[4:0]	ReadRegister1;
  wire[4:0]	ReadRegister2;
  wire[4:0]	WriteRegister;
  wire		RegWrite;
  wire		Clk;
  reg		begintest;

  // The register file being tested.  DUT = Device Under Test
  regfile DUT(ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
 
  // The test harness to test the DUT
  hw4testbench tester(begintest, endtest, dutpassed,ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);

initial begin
begintest=0;
#10;
begintest=1;
#1000;
end

always @(posedge endtest) begin
$display(dutpassed);
end

endmodule

// This is your actual test bench.
// It generates the signals to drive a registerfile and passes it back up one layer to the harness
//	((This lets us plug in various working / broken registerfiles to test
// When begintest is asserted, begin testing the register file.
// When your test is conclusive, set dutpassed as appropriate and then raise endtest.
module hw4testbench(begintest, endtest, dutpassed,
		    ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
output reg endtest;
output reg dutpassed;
input	   begintest;

input[31:0]		ReadData1;
input[31:0]		ReadData2;
output reg[31:0]	WriteData;
output reg[4:0]		ReadRegister1;
output reg[4:0]		ReadRegister2;
output reg[4:0]		WriteRegister;
output reg		RegWrite;
output reg		Clk;

initial begin
WriteData=0;
ReadRegister1=0;
ReadRegister2=0;
WriteRegister=0;
RegWrite=0;
Clk=0;
end

always @(posedge begintest) begin
endtest = 0;
dutpassed = 1;
#10

// Test Case 1: Write to 42 register 2, verify with Read Ports 1 and 2
// This will pass because the example register file is hardwired to always return 42.
WriteRegister = 2;
WriteData = 42;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;	// Generate Clock Edge
if(ReadData1 != 42 || ReadData2!= 42) begin
	dutpassed = 0;
	$display("Test Case 1 Failed");
	end

// Test Case 2: Write to 15 register 2, verify with Read Ports 1 and 2
// This will fail with the example register file, but should pass with yours.
WriteRegister = 2;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;
if(ReadData1 != 15 || ReadData2!= 15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 2 Failed");
	end

//We're done!  Wait a moment and signal completion.
#5
endtest = 1;
end

endmodule