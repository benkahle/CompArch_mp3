
// tests functionality of a 32 bit ALU
module Tester_ThirtyTwo_Bit_ALU;
reg [31:0]operandA;
reg [31:0]operandB;
reg [2:0] command;
wire [31:0]result;
wire carryout;
wire zero;
wire overflow;



ALU my_32_bit_ALU(
.result (result), 
.carryout (carryout), 
.zero (zero), 
.overflow (overflow), 
.operandA (operandA), 
.operandB (operandB), 
.command (command));


// http://www.random.org/bytes/ used to generate random 32 bit numbers
initial begin

$display("Command |               A                                   B                 | Cout               result               | Zero  OFL  | What are we testing?");

command = 3'b000;
operandA=32'b11101010111011000010000100011011;operandB=32'b11110011101011010110100000100010;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Addition", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b001;
operandA=32'b01101101001111000011101001011010;operandB=32'b01111000110000100010101001100001;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Subtract", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b010;
operandA=32'b01001001100010001011111000000100;operandB=32'b10111011001110101001101110001101;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | XOR", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b011;
operandA=32'b00010011111011100001110000000111;operandB=32'b11110100010101010110010100100011;  #10000 
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | SLT", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space


command = 3'b100;
operandA=32'b00001000001100110000000011011110;operandB=32'b01111001111110010011001001001111;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | AND", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b001;
operandA=32'b11011110011111000011110100100100;operandB=32'b11101101011010101000101010000100;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | Subtract", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b110;
operandA=32'b00100000101110111011111100101000;operandB=32'b00000110010101000010010100001000;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | NOR", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

command = 3'b111;
operandA=32'b00100001111111010101000011000000;operandB=32'b11110001110000010011101100100001;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | OR", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space

end
endmodule
