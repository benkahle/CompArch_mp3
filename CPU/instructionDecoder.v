module instructionDecoder(clk, instruction, pcSrc, regDst, regWrEn, aluSrcB, aluCommand, memWrEn, memOutSrc);
  input clk;
  input[31:0] instruction;
  output[2:0] aluCommand; //TODO: do we need to support all 7 operations? 
  output[1:0] pcSrc, memOutSrc;
  output regDst, regWrEn, memWrEn, aluSrcB;

endmodule

module instructionDecoderTest();
endmodule