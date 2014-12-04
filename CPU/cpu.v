module cpu();
	reg clk;
    #5 clk=1; #5 clk=0; #set clock to 10Mh

    reg[31:0] PC;	//Assuming a 32 bit program counter
    reg[31:0] instruction; 
    reg aluZero;

    //Control shit for Instruction Decoder
    //Remake these wires
    reg[4:0] rs, rt, rd;
    reg[2:0] aluCommand;
    reg[1:0] pcSrc, memOutSrc;
    reg[15:0] imm;
    reg[27:0] jImm;
    reg regDst, regWrEn, memWrEn, aluSrcB, extSel;
    wire aluZero;
    wire[1:0] writebackSrc;

    wire[31:0] pcPlus4;

    wire[31:0] WriteData;

    instructionMemory(clk, PC, instruction); 
    //Inputs: PC (the Addr for the Instruction Memory) and clk
    //Output: 32-bit instruction
    
    instructionDecoder(clk, instruction, pcSrc, regDst, regWrEn, extSel, aluSrcB, aluCommand, memWrEn, memOutSrc, writebackSrc, rs, rt, rd, imm, aluZero, jImm);


    wire[31:0] 32_bit_imm; 
    signextend (clk, extSel, imm, 32_bit_imm);
    //Inputs: clk, extSel and the 16-bit immediate from the instruction decoder
    //Output: 32 bit sign extended immediate


    muxRegDst (regDst, rt, rd, WriteRegister);
    //Based on regDst, selects rt or rd from the Instruction Decoder to go to the WriteRegister
    //Inputs: regDst, rt, rd
    //Output: WriteRegister

   	wire[31:0] ReadData1; //Not sure if these should be reg or wire...
   	wire[31:0] ReadData2;

    registerFile(ReadData1, ReadData2, WriteData, rs, rt, WriteRegister, regWrEn, clk);
    //Inputs: WriteData (wd), ReadRegister1 (rs) , ReadRegister2 (rt) , WriteRegister (rd), regWrEn (en)
    //Outputs: ReadData1(ra) , ReadData2(rb)

    wire[31:0] B; //The B input to the ALU
    muxAluSourceB(B, ReadData2, 32_bit_imm, aluSrcB);
    //

    wire[31:0] aluOut;

    ALU(aluOut, #carryout, aluZero, #overflow, ReadData1, B, aluCommand);
    //Inputs: 
    //Outputs: aluOut, aluZero, carryout

    wire[31:0] dataMemOut;
    dataMemory(clk, regWrEn, aluOut, ReadData2, dataMemOut);
    //Inputs:clk, regWrEn, aluOut, ReadData2
    //Output: dataMemOut

    muxWriteBackSrc(WriteData, writebackSrc, aluOut, dataMemOut, pcPlus4);


    wire[31:0] shiftLeftOut;
    shiftLeft2(shiftLeftOut, 32_bit_imm);

    wire[31:0] branch;
    adder(branch, shiftLeftOut, pcPlus4);

    wire[31:0] jAbs;
    jAbsConcat(jAbs, jImm, pcPlus4);

    muxPCSrc(PC, pcSrc, jAbs, ReadData1, pcPlus4, branch);




endmodule

module muxAluSourceB(B, ReadData2, 32_bit_imm, aluSrcB);
    input[31:0] ReadData2, 32_bit_imm;
    input aluSrcB;
    output[31:0] B;
endmodule

module muxRegDst(regDst, rt, rd, WriteRegister);
	input[4:0] rt, rd;
	input regDst;
	output[4:0] WriteRegister; 
endmodule

module muxWriteBackSrc(WriteData, writebackSrc, aluOut, dataMemOut, pcPlus4);
	input[1:0] writebackSrc;
	input[31:0] aluOut, dataMemOut, pcPlus4;
	output[31:0] WriteData;
endmodule

module shiftLeft2(shiftLeftOut, 32_bit_imm);
	input[31:0] 32_bit_imm;
	output[31:0] shiftLeftOut;

	assign shiftLeftOut = 32_bit_imm << 2;

endmodule

module muxPCSrc(PC, pcSrc, jAbs, ReadData1, pcPlus4, branch);
	input[31:0] jAbs, ReadData1, pcPlus4, branch;
	input[1:0] pcSrc;
	output[31:0] PC;

endmodule

module adder(branch, shiftLeftOut, pcPlus4);
	input[31:0] shiftLeftOut, pcPlus4;
	output[31:0] branch;
endmodule

module pcAdder(pcPlus4, PC);
	input[31:0] PC;
	output[31:0] pcPlus4;

	assign pcPlus4 = PC + 3'd4;
	
endmodule

module jAbsConcat(jAbs, jImm, pcPlus4);
	input[27:0] jImm;
	input[31:0] pcPlus4;
	output[31:0] jAbs;

	assign jAbs = {pcPlus4[31:27], jImm};

endmodule