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
module registerFile(ReadData1, // Contents of first register read
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

  wire [31:0]	WriteEnable;
  wire [31:0]	Q[31:0];	

  register32zero regZero(Q[0], WriteData, WriteEnable[0], Clk); 

  decoder1to32 decode(WriteEnable, RegWrite, WriteRegister);
  genvar i;
  generate 
    for (i = 1; i<32; i = i+1) begin: loop
      register32 register(Q[i], WriteData, WriteEnable[i], Clk);
    end
  endgenerate

  mux32to1by32 mux1(ReadData1, ReadRegister1, Q[0], Q[1], Q[2], Q[3], Q[4], Q[5], Q[6], Q[7], Q[8], Q[9], Q[10], Q[11], Q[12], Q[13], Q[14], Q[15], Q[16], Q[17], Q[18], Q[19], Q[20], Q[21], Q[22], Q[23], Q[24], Q[25], Q[26], Q[27], Q[28], Q[29], Q[30], Q[31]);
  mux32to1by32 mux2(ReadData2, ReadRegister2, Q[0], Q[1], Q[2], Q[3], Q[4], Q[5], Q[6], Q[7], Q[8], Q[9], Q[10], Q[11], Q[12], Q[13], Q[14], Q[15], Q[16], Q[17], Q[18], Q[19], Q[20], Q[21], Q[22], Q[23], Q[24], Q[25], Q[26], Q[27], Q[28], Q[29], Q[30], Q[31]);

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
  registerFile DUT(ReadData1,
		ReadData2,
		WriteData, 
		ReadRegister1, 
		ReadRegister2,
		WriteRegister,
		RegWrite, 
		Clk);
 
  // The test harness to test the DUT
  hw4testbench tester(begintest, 
			endtest, 
			dutpassed,
			ReadData1,
			ReadData2,
			WriteData, 
			ReadRegister1, 
			ReadRegister2,
			WriteRegister,
			RegWrite, 
			Clk);

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
module hw4testbench(begintest, 
			endtest,
			dutpassed,
		    	ReadData1,
			ReadData2,
			WriteData, 
			ReadRegister1, 
			ReadRegister2,
			WriteRegister,
			RegWrite, 
			Clk);
  output reg endtest;
  output reg dutpassed;
  input	   begintest;

  input[31:0]		ReadData1;
  input[31:0]		ReadData2;
  output reg[31:0]	WriteData;
  output reg[4:0]	ReadRegister1;
  output reg[4:0]	ReadRegister2;
  output reg[4:0]	WriteRegister;
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

    WriteRegister = 2;
    ReadRegister1 = 2;
    ReadRegister2 = 2;
    // Test Case 1: Write to 42 register 2, verify with Read Ports 1 and 2
    // This will pass because the example register file is hardwired to always return 42.
    WriteData = 42;
    RegWrite = 1;
    #5 Clk=1; #5 Clk=0;	// Generate Clock Edge
    if(ReadData1 != 42 || ReadData2!= 42) begin
	dutpassed = 0;
	$display("Test Case 1 Failed");
	end

    // Test Case 2: Write to 15 register 2, verify with Read Ports 1 and 2
    // This will fail with the example register file, but should pass with yours.
    WriteData = 15;
    #5 Clk=1; #5 Clk=0;
    if(ReadData1 != 15 || ReadData2!= 15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 2 Failed");
    end

    // Test Case 3: Write register is broken and always written to.
    RegWrite = 0;
    WriteData = 17;
    #5 Clk=1; #5 Clk=0;
    if(ReadData1 == 17 || ReadData2 == 17) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 3 Failed");
    end

    // Test Case 4: decoder is broken, all registers are written to
    WriteRegister = 3;
    WriteData = 19;
    RegWrite = 1;
    #5 Clk=1; #5 Clk=0;
    if(ReadData1 == 19 || ReadData2 == 19) begin
    	dutpassed = 0;	// On Failure, set to false.
    	$display("Test Case 4 Failed");
    end



    // Test Case 5: Register Zero is actually a register
    WriteRegister = 0;
    WriteData = 15;
    ReadRegister1 = 0;
    ReadRegister2 = 0;
    #5 Clk=1; #5 Clk=0;
    if(ReadData1 != 0 || ReadData2!= 0) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 5 Failed");
    end

    // Test Case 6: port 2 always reads register 17
    WriteRegister = 17;
    WriteData = 20;
    ReadRegister1 = 2;
    ReadRegister2 = 2;
    #5 Clk=1; #5 Clk=0;

    WriteRegister = 2;
    WriteData = 2;
    #5 Clk=1; #5 Clk=0;

    if(ReadData1 == 20 || ReadData2 == 20) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 6 Failed");
	end

    //We're done!  Wait a moment and signal completion.
    #5
    endtest = 1;
  end

endmodule
