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
    reg[31:0] WriteData;

    instructionMemory im(clk, pc, instruction); 
    //Inputs: pc (the Addr for the Instruction Memory) and clk
    //Output: 32-bit instruction
    
    instructionDecoder id(clk, instruction, pcSrc, regDst, regWrEn, extSel, aluSrcB, aluCommand, memWrEn, writebackSrc, rs, rt, rd, imm, aluZero, jImm);


    wire[31:0] full_imm; 
    signExtend se(clk, extSel, imm, full_imm);
    //Inputs: clk, extSel and the 16-bit immediate from the instruction decoder
    //Output: 32 bit sign extended immediate


    // muxRegDst mrd(clk, regDst, rt, rd, WriteRegister);
    //Based on regDst, selects rt or rd from the Instruction Decoder to go to the WriteRegister
    //Inputs: regDst, rt, rd
    //Output: WriteRegister

    wire[31:0] ReadData1; //Not sure if these should be reg or wire...
    wire[31:0] ReadData2;

    registerFile rf(ReadData1, ReadData2, WriteData, rs, rt, WriteRegister, regWrEn, clk);
    //Inputs: WriteData (wd), ReadRegister1 (rs) , ReadRegister2 (rt) , WriteRegister (rd), regWrEn (en)
    //Outputs: ReadData1(ra) , ReadData2(rb)

    wire [31:0] B; //The B input to the ALU

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


    wire[31:0] shiftLeftOut;

    wire[31:0] branch;

    wire[31:0] jAbs;
    
    //pcAdder
    assign pcPlus4 = pc + 3'd4;
    //shiftLeft2
    assign shiftLeftOut = full_imm << 2;
    //adder
    assign branch = shiftLeftOut + pcPlus4;
    //jAbsConcat
    assign jAbs = {pcPlus4[31:27], jImm};

    // Set WriteRegister Addres to rt or rd
    assign WriteRegister = (regDst) ? rt : rd;

    // Set ALU 2nd source to SE(imm) or Register2
    assign B = (aluSrcB) ? full_imm : ReadData2;
    
    always @(*) begin
      //muxWriteBackSrc
      if (writebackSrc == 2'd0) WriteData = aluOut;
      if (writebackSrc == 2'd1) WriteData = dataMemOut;
      if (writebackSrc == 2'd2) WriteData = pcPlus4;
    end

    always @(posedge clk) begin
      //muxPCSrc
      if (pcSrc == 2'd0) pc = pcPlus4;
      if (pcSrc == 2'd1) pc = ReadData1; // register indirect jump
      if (pcSrc == 2'd2) pc = jAbs;
      if (pcSrc == 2'd3) pc = branch;
    end

endmodule

module testCpu;

  reg clk;

  cpu cpu(clk);

  initial begin
    clk = 1;
  end

  always #5 clk = !clk; //Switch every 5 nanoseconds

endmodule
