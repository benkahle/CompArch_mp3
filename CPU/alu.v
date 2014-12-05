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

module aluTestBench;
reg [31:0]operandA;
reg [31:0]operandB;
reg [2:0] command;
wire [31:0]result;
wire carryout;
wire zero;
wire overflow;



alu alu32Bit(result, carryout, zero, overflow, operandA, operandB, command);


// http://www.random.org/bytes/ used to generate random 32 bit numbers
initial begin

$display("Command |               A                                   B                 | Cout               result               | Zero  OFL  | What are we testing?");

command = 3'b000;
operandA=32'b11101010111011000010000100011011;operandB=32'b11110011101011010110100000100010;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Addition", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b000;
operandA=32'b00010000000000000000000000000000;operandB=32'b11110000000000000000000000000000;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Addition", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b000;
operandA=32'b00000000000000000000000000000010;operandB=32'b00000000000000000000000000000010;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Addition", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b000;
operandA=32'b10000000000000000000000000000000;operandB=32'b10000000000000000000000000000000;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Addition", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b000;
operandA=32'b01010000000000000000000000000000;operandB=32'b01010000000000000000000000000000;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Addition", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space
$display(""); // put in some blank space

command = 3'b001;
operandA=32'b01101101001111000011101001011010;operandB=32'b01111000110000100010101001100001;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Subtract", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b001;
operandA=32'b11011110011111000011110100100100;operandB=32'b11101101011010101000101010000100;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Subtract", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space
$display(""); // put in some blank space

command = 3'b011;
operandA=32'b00010011111011100001110000000111;operandB=32'b11110100010101010110010100100011;  #10000 
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | SLT", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b011;
operandA=32'b00000000000000000000000000000011;operandB=32'b00000000000000000000000000000010;  #10000 
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | SLT", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space
$display(""); // put in some blank space

end
endmodule
