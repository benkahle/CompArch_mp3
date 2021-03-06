module cpu(clk);
	input clk;

    reg[31:0] pc;
    initial pc = 0;

    wire[31:0] instruction; 

    wire[4:0] rs, rt, rd, WriteRegister;
    wire[2:0] aluCommand;
    wire[1:0] pcSrc, memOutSrc;
    wire[15:0] imm;
    wire[27:0] jImm;
    wire regDst, regWrEn, memWrEn, aluSrcB, extSel;
    wire aluZero;
    wire[1:0] writebackSrc;

    wire[31:0] pcPlus4;

    wire[31:0] WriteData;

    instructionMemory im(clk, pc, instruction); 
    //Inputs: pc (the Addr for the Instruction Memory) and clk
    //Output: 32-bit instruction
    
    instructionDecoder id(clk, instruction, pcSrc, regDst, regWrEn, extSel, aluSrcB, aluCommand, memWrEn, writebackSrc, rs, rt, rd, imm, aluZero, jImm);


    wire[31:0] full_imm; 
    signExtend se(clk, extSel, imm, full_imm);
    //Inputs: clk, extSel and the 16-bit immediate from the instruction decoder
    //Output: 32 bit sign extended immediate


    muxRegDst mrd(clk, regDst, rt, rd, WriteRegister);
    //Based on regDst, selects rt or rd from the Instruction Decoder to go to the WriteRegister
    //Inputs: regDst, rt, rd
    //Output: WriteRegister

   	wire[31:0] ReadData1; //Not sure if these should be reg or wire...
   	wire[31:0] ReadData2;

    registerFile rf(ReadData1, ReadData2, WriteData, rs, rt, WriteRegister, regWrEn, clk);
    //Inputs: WriteData (wd), ReadRegister1 (rs) , ReadRegister2 (rt) , WriteRegister (rd), regWrEn (en)
    //Outputs: ReadData1(ra) , ReadData2(rb)

    wire[31:0] B; //The B input to the ALU
    muxAluSourceB mas(clk, B, ReadData2, full_imm, aluSrcB);
    //

    wire[31:0] aluOut;
    wire _carryout;
    wire _overflow;
    alu alu(aluOut, _carryout, aluZero, _overflow, ReadData1, B, aluCommand);
    //Inputs: 
    //Outputs: aluOut, aluZero, carryout

    wire[31:0] dataMemOut;
    dataMemory dm(clk, regWrEn, aluOut, ReadData2, dataMemOut);
    //Inputs:clk, regWrEn, aluOut, ReadData2
    //Output: dataMemOut

    muxWriteBackSrc mwbs(clk, WriteData, writebackSrc, aluOut, dataMemOut, pcPlus4);


    wire[31:0] shiftLeftOut;
    shiftLeft2 sl(clk, shiftLeftOut, full_imm);

    wire[31:0] branch;
    adder a(clk, branch, shiftLeftOut, pcPlus4);

    wire[31:0] jAbs;
    jAbsConcat c(jAbs, jImm, pcPlus4);

    pcAdder pca(clk, pcPlus4, pc);

    wire[31:0] newPc;
    muxPCSrc mpcs(clk, newPc, pcSrc, jAbs, ReadData1, pcPlus4, branch);

    always @(posedge clk) begin
      // $display("pc set to: %d", newPc);
      pc = newPc;
    end

endmodule

//Defining all of our muxes and other cute small things

module muxAluSourceB(clk, B, ReadData2, full_imm, aluSrcB);
  input clk;
  input[31:0] ReadData2, full_imm;
  input aluSrcB;
  output reg[31:0] B;
  always @(*) begin
    if(!aluSrcB) B = ReadData2;
    else B = full_imm;
  end
endmodule

module muxRegDst(clk, regDst, rt, rd, WriteRegister);
  input clk;
	input[4:0] rt, rd;
	input regDst;
	output reg[4:0] WriteRegister; 
  always @(*) begin
  	if (!regDst) WriteRegister = rd;
  	else  WriteRegister = rt;
  end
endmodule

module muxWriteBackSrc(clk, WriteData, writebackSrc, aluOut, dataMemOut, pcPlus4);
  input clk;
	input[1:0] writebackSrc;
	input[31:0] aluOut, dataMemOut, pcPlus4;
	output reg[31:0] WriteData;
  always @(*) begin
  	if (!writebackSrc) WriteData = aluOut;
  	if (writebackSrc == 2'd1) WriteData = dataMemOut;
  	if (writebackSrc == 2'd2) WriteData = pcPlus4;
  end
endmodule

module shiftLeft2(clk, shiftLeftOut, full_imm);
  input clk;
	input[31:0] full_imm;
	output [31:0] shiftLeftOut;
  assign shiftLeftOut = full_imm << 2;
endmodule

module muxPCSrc(clk, newPc, pcSrc, jAbs, rInd, pcPlus4, branch);
  input clk;
	input[31:0] jAbs, pcPlus4, branch, rInd;
	input[1:0] pcSrc;
	output[31:0] newPc;
  always @(*) begin
    // $display("pcSrc = %d", pcSrc);
  	if (pcSrc == 2'd0) newPc = pcPlus4;
  	if (pcSrc == 2'd1) newPc = rInd;
  	if (pcSrc == 2'd2) newPc = jAbs;
  	if (pcSrc == 2'd3) newPc = branch;
  end
endmodule

module adder(clk, branch, shiftLeftOut, pcPlus4);
	input clk;
  input[31:0] shiftLeftOut, pcPlus4;
	output[31:0] branch;
  assign branch = shiftLeftOut + pcPlus4;
endmodule

module pcAdder(clk, pcPlus4, pc);
  input clk;
	input[31:0] pc;
	output[31:0] pcPlus4;
  assign pcPlus4 = pc + 3'd4;
endmodule

module jAbsConcat(jAbs, jImm, pcPlus4);
	input[27:0] jImm;
	input[31:0] pcPlus4;
	output[31:0] jAbs;

	assign jAbs = {pcPlus4[31:27], jImm};

endmodule

module testCpu;

	reg clk;

	cpu cpu(clk);

	initial begin
    clk = 0;
  end

	always #5 clk = !clk; //Switch every 5 nanoseconds

endmodule
