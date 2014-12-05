/////////////////////////
// Ruby Spring - HW4
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

  initial q = 32'b0;
  always @(posedge clk) begin
    q = 32'b0;
  end
endmodule
module mux32to1by32(out, address, input0, input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12, input13, input14, input15, input16, input17, input18, input19, input20, input21, input22, input23, input24, input25, input26, input27, input28, input29, input30, input31);
  input[31:0] input0, input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12, input13, input14, input15, input16, input17, input18, input19, input20, input21, input22, input23, input24, input25, input26, input27, input28, input29, input30, input31;
  input[4:0] address;
  output[31:0] out;

  wire[31:0] mux[31:0];
  assign mux[0] = input0;
  assign mux[1] = input1;
  assign mux[2] = input2;
  assign mux[3] = input3;
  assign mux[4] = input4;
  assign mux[5] = input5;
  assign mux[6] = input6;
  assign mux[7] = input7;
  assign mux[8] = input8;
  assign mux[9] = input9;
  assign mux[10] = input10;
  assign mux[11] = input11;
  assign mux[12] = input12;
  assign mux[13] = input13;
  assign mux[14] = input14;
  assign mux[15] = input15;
  assign mux[16] = input16;
  assign mux[17] = input17;
  assign mux[18] = input18;
  assign mux[19] = input19;
  assign mux[20] = input20;
  assign mux[21] = input21;
  assign mux[22] = input22;
  assign mux[23] = input23;
  assign mux[24] = input24;
  assign mux[25] = input25;
  assign mux[26] = input26;
  assign mux[27] = input27;
  assign mux[28] = input28;
  assign mux[29] = input29;
  assign mux[30] = input30;
  assign mux[31] = input31;

  assign out = mux[address]; // Connects the output of the array
endmodule
module decoder1to32(out, enable, address);
  output[31:0] out;
  input enable;
  input[4:0] address;
 
  assign out = enable<<address; 
endmodule
module registerFile(readData1, // Contents of first register read
 		readData2, // Contents of second register read
 		writeData, // Contents to write to register
 		readRegister1, // Address of first register to read 
 		readRegister2, // Address of second register to read
		writeRegister, // Address of register to write
 		regWrite, // Enable writing of register when High
 		clk); // Clock (Positive Edge Triggered)
  output[31:0]	readData1;
  output[31:0]	readData2;
  input[31:0]	writeData;
  input[4:0]	readRegister1;
  input[4:0]	readRegister2;
  input[4:0]	writeRegister;
  input		regWrite;
  input		clk;

  wire [31:0]	WriteEnable;
  wire [31:0]	Q[31:0];	

  register32zero regZero(Q[0], writeData, WriteEnable[0], clk); 

  decoder1to32 decode(WriteEnable, regWrite, writeRegister);
  genvar i;
  generate 
    for (i = 1; i<32; i = i+1) begin: loop
      register32 register(Q[i], writeData, WriteEnable[i], clk);
    end
  endgenerate

  mux32to1by32 mux1(readData1, readRegister1, Q[0], Q[1], Q[2], Q[3], Q[4], Q[5], Q[6], Q[7], Q[8], Q[9], Q[10], Q[11], Q[12], Q[13], Q[14], Q[15], Q[16], Q[17], Q[18], Q[19], Q[20], Q[21], Q[22], Q[23], Q[24], Q[25], Q[26], Q[27], Q[28], Q[29], Q[30], Q[31]);
  mux32to1by32 mux2(readData2, readRegister2, Q[0], Q[1], Q[2], Q[3], Q[4], Q[5], Q[6], Q[7], Q[8], Q[9], Q[10], Q[11], Q[12], Q[13], Q[14], Q[15], Q[16], Q[17], Q[18], Q[19], Q[20], Q[21], Q[22], Q[23], Q[24], Q[25], Q[26], Q[27], Q[28], Q[29], Q[30], Q[31]);

  //assign readData1 = 42;
  //assign readData2 = 42;
endmodule
module hw4testbenchharness;
  wire[31:0]	readData1;
  wire[31:0]	readData2;
  wire[31:0]	writeData;
  wire[4:0]	readRegister1;
  wire[4:0]	readRegister2;
  wire[4:0]	writeRegister;
  wire		regWrite;
  wire		clk;
  reg		beginTest;

  // The register file being tested.  DUT = Device Under Test
  registerFile DUT(readData1,
		readData2,
		writeData, 
		readRegister1, 
		readRegister2,
		writeRegister,
		regWrite, 
		clk);
 
  // The test harness to test the DUT
  hw4testbench tester(beginTest, 
			endTest, 
			dutPassed,
			readData1,
			readData2,
			writeData, 
			readRegister1, 
			readRegister2,
			writeRegister,
			regWrite, 
			clk);

initial begin
beginTest=0;
#10;
beginTest=1;
#1000;
end

always @(posedge endTest) begin
  $display(dutPassed);
end

endmodule
module hw4testbench(beginTest, 
			endTest,
			dutPassed,
		    	readData1,
			readData2,
			writeData, 
			readRegister1, 
			readRegister2,
			writeRegister,
			regWrite, 
			clk);
  output reg endTest;
  output reg dutPassed;
  input	   beginTest;

  input[31:0]		readData1;
  input[31:0]		readData2;
  output reg[31:0]	writeData;
  output reg[4:0]	readRegister1;
  output reg[4:0]	readRegister2;
  output reg[4:0]	writeRegister;
  output reg		regWrite;
  output reg		clk;

  initial begin
    writeData=0;
    readRegister1=0;
    readRegister2=0;
    writeRegister=0;
    regWrite=0;
    clk=0;
  end

  always @(posedge beginTest) begin
    endTest = 0;
    dutPassed = 1;
    #10

    writeRegister = 2;
    readRegister1 = 2;
    readRegister2 = 2;
    // Test Case 1: Write to 42 register 2, verify with Read Ports 1 and 2
    // This will pass because the example register file is hardwired to always return 42.
    writeData = 42;
    regWrite = 1;
    #5 clk=1; #5 clk=0;	// Generate Clock Edge
    if(readData1 != 42 || readData2!= 42) begin
	dutPassed = 0;
	$display("Test Case 1 Failed");
	end

    // Test Case 2: Write to 15 register 2, verify with Read Ports 1 and 2
    // This will fail with the example register file, but should pass with yours.
    writeData = 15;
    #5 clk=1; #5 clk=0;
    if(readData1 != 15 || readData2!= 15) begin
	dutPassed = 0;	// On Failure, set to false.
	$display("Test Case 2 Failed");
    end

    // Test Case 3: Write register is broken and always written to.
    regWrite = 0;
    writeData = 17;
    #5 clk=1; #5 clk=0;
    if(readData1 == 17 || readData2 == 17) begin
	dutPassed = 0;	// On Failure, set to false.
	$display("Test Case 3 Failed");
    end

    // Test Case 4: decoder is broken, all registers are written to
    writeRegister = 3;
    writeData = 19;
    regWrite = 1;
    #5 clk=1; #5 clk=0;
    if(readData1 == 19 || readData2 == 19) begin
    	dutPassed = 0;	// On Failure, set to false.
    	$display("Test Case 4 Failed");
    end



    // Test Case 5: Register Zero is actually a register
    writeRegister = 0;
    writeData = 15;
    readRegister1 = 0;
    readRegister2 = 0;
    #5 clk=1; #5 clk=0;
    if(readData1 != 0 || readData2!= 0) begin
	dutPassed = 0;	// On Failure, set to false.
	$display("Test Case 5 Failed");
    end

    // Test Case 6: port 2 always reads register 17
    writeRegister = 17;
    writeData = 20;
    readRegister1 = 2;
    readRegister2 = 2;
    #5 clk=1; #5 clk=0;

    writeRegister = 2;
    writeData = 2;
    #5 clk=1; #5 clk=0;

    if(readData1 == 20 || readData2 == 20) begin
	dutPassed = 0;	// On Failure, set to false.
	$display("Test Case 6 Failed");
	end

    //We're done!  Wait a moment and signal completion.
    #5
    endTest = 1;
  end

endmodule
