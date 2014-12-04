module instructionDecoder(clk, instruction, pcSrc, regDst, regWrEn, extSel, aluSrcB, aluCommand, memWrEn, memOutSrc, rs, rt, rd, imm, aluZero);
  input clk, aluZero;
  input[31:0] instruction;
  output reg[15:0] imm;
  output reg[4:0] rs, rt, rd;
  output reg[2:0] aluCommand; //TODO: do we need to support all 7 operations? 
  output reg[1:0] pcSrc, memOutSrc;
  output reg regDst, regWrEn, memWrEn, aluSrcB, extSel;

  always @(posedge clk) begin
    // Set defaults
    rs = 5'd0;
    rt = 5'd0;
    rd = 5'd0;
    imm = 15'd0;
    pcSrc = 2'd0; // pc+4
    regDst = 0; // rd
    regWrEn = 0; // No Write
    aluSrcB = 0; // register
    extSel = 0; // signed extension 
    aluCommand = 3'd0; // ALU ADD
    memWrEn = 0; // No Write
    memOutSrc = 2'd0; // ALU
    rs = instruction[25:21];
    rt = instruction[20:16];
    rd = instruction[15:11];
    imm = instruction[15:0];

    //Check Opcode to determine instruction type
    case(instruction[31:26])
      6'b000000: begin // R-Type instruction
        case(instruction[5:0]) //Check Funct to determine operation
          6'd8: begin // jr
            pcSrc = 2'd1; // Reg indirect
          end

          6'd32: begin // add
            // rd = rs + rt
            regDst = 0; // rd
            regWrEn = 1; // Write back enable
          end

          6'd12: begin //Syscall!
            $stop;
          end
        endcase
      end
      // J-Type Instructions
      6'd2: begin // j
        pcSrc = 2'd2; // J Absolute
      end

      6'd3: begin // jal
        rd = 5'd31; // Special register for $ra
        regWrEn = 1; // Write back enable
        memOutSrc = 2'd2; // PC+4
        pcSrc = 2'd2; // J Absolute
      end

      // I-Type Instructions
      6'd4: begin // beq
        aluCommand = 3'd2;
        if (aluZero) begin
          pcSrc = 2'd3; // br
        end 
      end

      6'd5: begin // bne
        aluCommand = 3'd2;
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
       memOutSrc = 2'd1; // Mem
      end

      6'd43: begin // sw
        // mem[rs+imm]:4 = rt
        aluSrcB = 1; // Use immediate in ALU calc (displacement)
      end
    endcase
  end

endmodule

module testBench;
endmodule