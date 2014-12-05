module instructionDecoder(clk, instruction, pcSrc, regDst, regWrEn, extSel, aluSrcB, aluCommand, memWrEn, writebackSrc, rs, rt, rd, imm, aluZero, jImm);
  input clk, aluZero;
  input[31:0] instruction;
  output reg[15:0] imm;
  output reg[4:0] rs, rt, rd;
  output reg[2:0] aluCommand;
  output reg[1:0] pcSrc, writebackSrc;
  output reg regDst, regWrEn, memWrEn, aluSrcB, extSel;
  output reg[27:0] jImm;

  always @(*) begin
    // Set defaults
    pcSrc = 2'd0; // pc+4
    rs = 5'd0;
    rt = 5'd0;
    rd = 5'd0;
    imm = 15'd0;
    regDst = 0; // rd
    regWrEn = 0; // No Write
    aluSrcB = 0; // register
    extSel = 0; // signed extension 
    aluCommand = 3'd0; // ALU ADD
    memWrEn = 0; // No Write
    writebackSrc = 2'd0; // ALU
    rs = instruction[25:21];
    rt = instruction[20:16];
    rd = instruction[15:11];
    imm = instruction[15:0];
    jImm = 28'd0;
    //Check Opcode to determine instruction type
    case(instruction[31:26])
      6'b000000: begin // R-Type instruction
        case(instruction[5:0]) // Check Funct to determine operation
          6'd8: begin // jr
            pcSrc = 2'd1; // Reg indirect
          end

          6'd32: begin // add
            // rd = rs + rt
            regDst = 0; // rd
            regWrEn = 1; // Write back enable
          end

          6'd12: begin //Syscall!
            $display("Done!");
            $stop;
          end
        endcase
      end

      6'd3: begin // jal
        rd = 5'd31; // Special register for $ra
        regWrEn = 1; // Write back enable
        writebackSrc = 2'd2; // PC+4
        pcSrc = 2'd2; // J Absolute
        jImm = instruction[25:0] << 2;
      end

      // I-Type Instructions
      6'd4: begin // beq
        aluCommand = 3'd1;
        if (aluZero) begin
          pcSrc = 2'd3; // br
        end 
      end

      6'd5: begin // bne
        aluCommand = 3'd1;
        if (!aluZero) begin
          pcSrc = 2'd3; // br (dependent on result of conditional?)
        end
      end

      6'd8: begin // addi
        aluSrcB = 1; // Use immediate in ALU calc
        regDst = 1; // rt
        regWrEn = 1; // Write back enable
      end

      6'd9: begin // addiu
        // rt = rs + uSE(Imm)
        aluSrcB = 1; // Use immediate in ALU calc
        extSel = 1; // Unsigned extension
        regDst = 1; // rt
        regWrEn = 1; // Write back enable
      end

      6'd10: begin // slti
        // rt = rs < SE(Imm)
        aluSrcB = 1; // Use immediate in ALU calc
        aluCommand = 3'd3; // ALU SLT
        regDst = 1; // rt
        regWrEn = 1; // Write back enable
      end

      6'd35: begin // lw
       // rt = mem[rs+imm]:4 TODO: ensure division by 4 is working
       regDst = 1; // rt
       regWrEn = 1; // Write back enable
       aluSrcB = 1; // Use immediate in ALU calc (displacement)
       writebackSrc = 2'd1; // Mem
      end

      6'd43: begin // sw
        // mem[rs+imm]:4 = rt
        aluSrcB = 1; // Use immediate in ALU calc (displacement)
        memWrEn = 1;
      end
    endcase
  end

endmodule

module testInstructionDecoder;
  reg clk;
  reg aluZero;
  reg[31:0] instruction;
  wire[27:0] jImm;
  wire[15:0] imm;
  wire[4:0] rs, rt, rd;
  wire[2:0] aluCommand;
  wire[1:0] pcSrc, writebackSrc;
  wire regDst, regWrEn, memWrEn, aluSrcB, extSel;

  instructionDecoder dec(clk, instruction, pcSrc, regDst, regWrEn, extSel, aluSrcB, aluCommand, memWrEn, writebackSrc, rs, rt, rd, imm, aluZero, jImm);

  initial begin

    // addi
    instruction = {6'd8,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd1) $display("addi Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("addi Failure: rt is %d when expected %d", rt, rt); 
    if (rd != 5'd0) $display("addi Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("addi Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd0) $display("addi Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("addi Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 1) $display("addi Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("addi Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("addi Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 1) $display("addi Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 1) $display("addi Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("addi Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("addi Failure: jImm is %d when expected %d", jImm, jImm);
     
    // add
    instruction = {6'd0,5'd1,5'd2,5'd3,5'd0,6'd32};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd1) $display("add Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("add Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd3) $display("add Failure: rd is %d when expected %d", rd, rd);
    if (aluCommand != 3'd0) $display("add Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("add Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("add Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("add Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("add Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("add Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 1) $display("add Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("add Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("add Failure: jImm is %d when expected %d", jImm, jImm);
    
    // addiu
    instruction = {6'd9,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd1) $display("addiu Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("addiu Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("addiu Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("addiu Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd0) $display("addiu Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("addiu Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 1) $display("addiu Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("addiu Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 1) $display("addiu Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 1) $display("addiu Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 1) $display("addiu Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("addiu Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("addiu Failure: jImm is %d when expected %d", jImm, jImm);
    
    // slti
    instruction = {6'd10,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd1) $display("slti Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("slti Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("slti Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("slti Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd3) $display("slti Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("slti Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 1) $display("slti Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("slti Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("slti Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 1) $display("slti Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 1) $display("slti Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("slti Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("slti Failure: jImm is %d when expected %d", jImm, jImm);
    
    // sw
    instruction = {6'd43,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd1) $display("sw Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("sw Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("sw Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("sw Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd0) $display("sw Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("sw Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("sw Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("sw Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("sw Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 1) $display("sw Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 0) $display("sw Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 1) $display("sw Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("sw Failure: jImm is %d when expected %d", jImm, jImm);
    
    // lw
    instruction = {6'd35,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd1) $display("lw Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("lw Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("lw Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("lw Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd0) $display("lw Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("lw Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 1) $display("lw Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd1) $display("lw Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("lw Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 1) $display("lw Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 1) $display("lw Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("lw Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("lw Failure: jImm is %d when expected %d", jImm, jImm);
    
    // jal
    instruction = {6'd3,26'd14};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd0) $display("jal Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd0) $display("jal Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd31) $display("jal Failure: rd is %d when expected %d", rd, rd);
    if (aluCommand != 3'd0) $display("jal Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd2) $display("jal Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("jal Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd2) $display("jal Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("jal Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("jal Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 1) $display("jal Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("jal Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 56) $display("jal Failure: jImm is %d when expected %d", jImm, jImm);
    
    // jr
    instruction = {6'd0,5'd31,5'd0,5'd0,5'd0,6'd8};
    #5 clk=1; #5 clk=0;
    if (rs != 5'd31) $display("jr Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd0) $display("jr Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("jr Failure: rd is %d when expected %d", rd, rd);
    if (aluCommand != 3'd0) $display("jr Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd1) $display("jr Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("jr Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("jr Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("jr Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("jr Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 0) $display("jr Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("jr Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("jr Failure: jImm is %d when expected %d", jImm, jImm);
    
    // bne (not equal);
    aluZero = 0;
    instruction = {6'd5,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk = 0;
    if (rs != 5'd1) $display("bne (not equal) Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("bne (not equal) Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("bne (not equal) Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("bne (not equal) Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd2) $display("bne (not equal) Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd3) $display("bne (not equal) Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("bne (not equal) Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("bne (not equal) Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("bne (not equal) Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("bne (not equal) Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 0) $display("bne (not equal) Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("bne (not equal) Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("bne (not equal) Failure: jImm is %d when expected %d", jImm, jImm);
    
    // bne (equal);
    aluZero = 1;
    instruction = {6'd5,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk = 0;
    if (rs != 5'd1) $display("bne (equal) Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("bne (equal) Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("bne (equal) Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("bne (equal) Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd2) $display("bne (equal) Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("bne (equal) Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("bne (equal) Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("bne (equal) Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("bne (equal) Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("bne (equal) Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 0) $display("bne (equal) Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("bne (equal) Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("bne (equal) Failure: jImm is %d when expected %d", jImm, jImm);
    
    // beq (not equal);
    aluZero = 0;
    instruction = {6'd4,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk = 0;
    if (rs != 5'd1) $display("beq (not equal) Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("beq (not equal) Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("beq (not equal) Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("beq (not equal) Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd2) $display("beq (not equal) Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd0) $display("beq (not equal) Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("beq (not equal) Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("beq (not equal) Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("beq (not equal) Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("beq (not equal) Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 0) $display("beq (not equal) Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("beq (not equal) Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("beq (not equal) Failure: jImm is %d when expected %d", jImm, jImm);
    
    // beq (equal);
    aluZero = 1;
    instruction = {6'd4,5'd1,5'd2,16'd1};
    #5 clk=1; #5 clk = 0;
    if (rs != 5'd1) $display("beq (equal) Failure: rs is %d when expected %d", rs, rs);
    if (rt != 5'd2) $display("beq (equal) Failure: rt is %d when expected %d", rt, rt);
    if (rd != 5'd0) $display("beq (equal) Failure: rd is %d when expected %d", rd, rd);
    if (imm != 15'd1) $display("beq (equal) Failure: imm is %d when expected %d", imm, imm);
    if (aluCommand != 3'd2) $display("beq (equal) Failure: aluCommand is %d when expected %d", aluCommand, aluCommand);
    if (pcSrc != 2'd3) $display("beq (equal) Failure: pcSrc is %d when expected %d", pcSrc, pcSrc);
    if (regDst != 0) $display("beq (equal) Failure: regDst is %d when expected %d", regDst, regDst);
    if (writebackSrc != 2'd0) $display("beq (equal) Failure: writebackSrc is %d when expected %d", writebackSrc, writebackSrc);
    if (extSel != 0) $display("beq (equal) Failure: extSel is %d when expected %d", extSel, extSel);
    if (aluSrcB != 0) $display("beq (equal) Failure: aluSrcB is %d when expected %d", aluSrcB, aluSrcB);
    if (regWrEn != 0) $display("beq (equal) Failure: regWrEn is %d when expected %d", regWrEn, regWrEn);
    if (memWrEn != 0) $display("beq (equal) Failure: memWrEn is %d when expected %d", memWrEn, memWrEn);
    if (jImm != 0) $display("beq (equal) Failure: jImm is %d when expected %d", jImm, jImm);
    
  end
endmodule
