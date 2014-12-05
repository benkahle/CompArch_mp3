module alu(aluResult, carryOut, zero, overflow, opA, opB, aluCommand);
  input [2:0] aluCommand;
  input [31:0] opA, opB;
  output reg overflow, zero, carryOut;
  output reg [31:0] aluResult;

  always @(*) begin
    overflow = 0;
    carryOut = 0;
    case(aluCommand)
      3'd0: //add
        begin
          aluResult = opA + opB;
        end
      3'd1: //sub
        begin
          aluResult = opA - opB;
        end
      3'd3: //slt
        begin
          aluResult = (opA < opB) ? 1 : 0;
        end
    endcase
    zero = (aluResult) ? 0 : 1;
  end
endmodule