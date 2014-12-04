`define AND2 and #30 // 2 input NAND gate followed by 1 input inverter == 30 units of time
`define OR2 or #30 // 2 input NOR gate followed by 1 input inverter == 30 units of time
`define NOT not #10 // by definition, NOT gate has 1 input == 10 units of time
`define XOR2 xor #60 // ?? based on a circuit for a XOR gate using four NAND gates, where the worst case path propogates through
// three of them. All NAND gates are 2 input, so this makes a delay of 6 inputs == 60 units of time
`define NAND2 nand #20 // basic 2 input NAND
`define NOR2 nor #20 // basic 2 input NOR

// this module serves to calculate one bit of a alu, given a command to preform one of eight different
// arithmatic operations.
module alu_Bitslice(result_i, A_i, B_i, carryin, carryout, command);

// setting up all inputs and wires that will be used
input A_i;
input B_i;
input [2:0] command;
input carryin;
output result_i;
output carryout;

wire [2:0]mux_command; //since some commands will reuse components (ie, 000 and 001 are ADD and SUB, but
// both use the one bit adder, and have the same entry in the final muxer), this is 
// the command that actually goes to the muxer.
wire SUB_command; // are we subtracting? if so, we need to invert b

// all the results from our indevidual operations
wire result_add;
wire result_sub;
wire result_xor;
wire result_slt;
wire result_and;
wire result_nand;
wire result_nor;
wire result_or;

wire carryout_add;

// -----------------------------------------------------------------------------------------------
// generating control lines. Note that this is inefficient to have this LUT copied in every
// bitslice, but I trust my synthesiser to remove most of them, and it keeps things more readable
// (I don't have to pass around as many control wires between modules)

alucontrolLUT myLUT (
.muxindex (mux_command), 
.SUB_command (SUB_command), 
.aluCommand (command),
.not_SLT_mode (          ), // not used at the bitslice level, only for the full alu
.add_or_sub_mode (         ));


// -----------------------------------------------------------------------------------------------
// Arithmetic operations

wire invert_B_for_sub;
`XOR2(invert_B_for_sub, B_i, SUB_command);
// option one: add, subtract, SLT
One_Bit_FullAdder myAdder(
.sum (result_add),
.carryout (carryout),
.a (A_i),
.b (invert_B_for_sub),
.carryin (carryin));

// option three: XOR
`XOR2(result_xor, A_i, B_i);

// option five: AND
// we could reuse NAND, by using another mux to optionally invert the entire output. this is also true for
// OR. We decided not to. both solutions are valid. The timing delays in the `define section account for the 
// different gate types
`AND2(result_and, A_i, B_i);

// option six: NAND
`NAND2(result_nand, A_i, B_i);

// option seven: NOR
`NOR2(result_nor, A_i, B_i);

// option eight: OR
`OR2(result_or, A_i, B_i);

// -----------------------------------------------------------------------------------------------
// now, time to mux all the results!
wire [7:0]muxer_result_bundle; // because our muxer expects a bus, rather than a bunch of independant wires
assign muxer_result_bundle[0] = result_add; // also the result for sub and SLT
assign muxer_result_bundle[1] = result_xor;
assign muxer_result_bundle[2] = result_and;
assign muxer_result_bundle[3] = result_nand;
assign muxer_result_bundle[4] = result_nor;
assign muxer_result_bundle[5] = result_or;

Eight_Bit_Muxer result_decider(
.out (result_i),
.address (mux_command),
.in (muxer_result_bundle));


endmodule



`define AND2 and #30 // 2 input NAND gate followed by 1 input inverter == 30 units of time
`define OR2 or #30 // 2 input NOR gate followed by 1 input inverter == 30 units of time
`define NOT not #10 // by definition, NOT gate has 1 input == 10 units of time
`define XOR2 xor #60 // ?? based on a circuit for a XOR gate using four NAND gates, where the worst case path propogates through
// three of them. All NAND gates are 2 input, so this makes a delay of 6 inputs == 60 units of time

// basic one bit full adder. takes a,b,carryin, sums them and provides a carryout and sum.
module One_Bit_FullAdder(sum, carryout, a, b, carryin);
output sum, carryout;
input a, b, carryin;

wire AxorB, AnB, CnAxorB; // see a schematic for a full adder to understand why these wires are useful.

`XOR2(AxorB, a, b); // there may be a more time efficient way to do this: XOR gates are time intensive in my model.
// however, I trust my synthesiser to find the most time efficient transistor layout anyways, so for simulation this is
// sufficient.
`XOR2(sum, AxorB, carryin);
`AND2(AnB, a, b);
`AND2(CnAxorB, AxorB, carryin);
`OR2(carryout, CnAxorB, AnB);

endmodule



`define AND4 and #50 // 4 input NAND gate followed by 1 input inverter == 50 units of time
`define OR8 or #90 // 8 input NOR gate followed by 1 input inverter == 90 units of time
`define NOT not #10 // by definition, NOT gate has 1 input == 10 units of time

// this is an eight bit multiplexer that takes an eight bit input, and a three bit
// command input, and uses the command to decide which input should be sent forward
// to the output
module Eight_Bit_Muxer(out, address, in);
output out;
input [2:0]address;
input [7:0]in;

wire [7:0]combo;
wire [2:0]n_address;

// we need the NOT addresses as well
`NOT(n_address[0], address[0]);
`NOT(n_address[1], address[1]);
`NOT(n_address[2], address[2]);

// anding the indevidual inputs to their command bits
`AND4(combo[0], in[0], n_address[2], n_address[1], n_address[0]);
`AND4(combo[1], in[1], n_address[2], n_address[1],   address[0]);
`AND4(combo[2], in[2], n_address[2],   address[1], n_address[0]);
`AND4(combo[3], in[3], n_address[2],   address[1],   address[0]);
`AND4(combo[4], in[4],   address[2], n_address[1], n_address[0]);
`AND4(combo[5], in[5],   address[2], n_address[1],   address[0]);
`AND4(combo[6], in[6],   address[2],   address[1], n_address[0]);
`AND4(combo[7], in[7],   address[2],   address[1],   address[0]);

// creating the final output
`OR8(out, combo[0], combo[1], combo[2], combo[3], combo[4], combo[5], combo[6], combo[7]);
endmodule






// added the 'OP' because some of these names are already gates
`define OP_ADD 3'd0
`define OP_SUB 3'd1
`define OP_XOR 3'd2
`define OP_SLT 3'd3
`define OP_AND 3'd4
`define OP_NAND 3'd5
`define OP_NOR 3'd6
`define OP_OR 3'd7

// this LUT, source code provided largely by Eric, takes a three bit command (aluCommand),
// which determines what operation needs to be preformed, and returns all the neccessary
// control lines to make this happen. 
module alucontrolLUT(muxindex, SUB_command, aluCommand , not_SLT_mode, add_or_sub_mode);
output reg not_SLT_mode; // used to set all outputs to zero during SLT mode
output reg add_or_sub_mode; // used to disable the carryout during any mode but add and subtract.
output reg[2:0] muxindex; // controls the MUX at the end of each bitslice
output reg SUB_command; // are we subtracting or not?
input[2:0] aluCommand; // the input command

// here is the actual LUT, in behaviorial verilog
always @(aluCommand) begin 
	case (aluCommand)
	`OP_ADD:  begin muxindex = 0; SUB_command=0; not_SLT_mode=1; add_or_sub_mode=1; end
	`OP_SUB:  begin muxindex = 0; SUB_command=1; not_SLT_mode=1; add_or_sub_mode=1; end
	`OP_SLT:  begin muxindex = 0; SUB_command=1; not_SLT_mode=0; add_or_sub_mode=0; end
	`OP_XOR:  begin muxindex = 1; SUB_command=0; not_SLT_mode=1; add_or_sub_mode=0; end
	`OP_AND:  begin muxindex = 2; SUB_command=0; not_SLT_mode=1; add_or_sub_mode=0; end
	`OP_NAND: begin muxindex = 3; SUB_command=0; not_SLT_mode=1; add_or_sub_mode=0; end
	`OP_NOR:  begin muxindex = 4; SUB_command=0; not_SLT_mode=1; add_or_sub_mode=0; end
	`OP_OR:   begin muxindex = 5; SUB_command=0; not_SLT_mode=1; add_or_sub_mode=0; end
	endcase
end
endmodule





`define num_bits 8'd32 // how many bits do you want your alu to be? This module is fully parameterized by this define.

`define AND2 and #30 // 2 input NAND gate followed by 1 input inverter == 30 units of time
`define OR2 or #30 // 2 input NOR gate followed by 1 input inverter == 30 units of time
`define NOT not #10 // by definition, NOT gate has 1 input == 10 units of time
`define XOR2 xor #60 // ?? based on a circuit for a XOR gate using four NAND gates, where the worst case path propogates through
// three of them. All NAND gates are 2 input, so this makes a delay of 6 inputs == 60 units of time


// this alu can preform the 8 basic operations requested by MP1.
module alu(result, carryout, zero, overflow, operandA, operandB, command);
output[(`num_bits-1):0] result; 
output carryout; 
output zero; // this is one if the result is zero (every bit in the result bus is a zero)
output overflow;
input[(`num_bits-1):0] operandA; // inputs A and B. each are n-bits
input[(`num_bits-1):0] operandB;
input[2:0] command; // three bit command telling the alu what to do. This gets parsed through a LUT


// this wire is used for connecting the carry chain for the adder
wire [`num_bits:0]internal_carrys; // one extra index (length n+1), since internal_carrys[0] is actually the initial carryin
wire [(`num_bits-1):0]results_raw; // the 'results' straight out of the bitslices. still needs some conditioning
// before they are ready to leave the alu.
wire first_bit; // the first bit straight out of the bit slice. This bit needs even more conditioning, since during SLT it
// may also be set to one. Therefore, this bit doesn't go into the results_raw.
wire initial_carryin_for_subtraction; // if we are subtracting (based on output from LUT), then we need a carryin to the adder chain.
wire overflow_raw; // checking for overflow based on last bit carryin not equaling last bit carryout.
// considered 'raw' because overflows may occur during SLT or other operations, but only during addition
// and subtraction do we actually want to flag overflows.

wire AlessthanB; // this tells us if A<B, and we are in SLT mode. Used for returning the zeroth bit to 1. 
wire not_SLT_mode; // This comes from the lookup table, and tells us if we are in SLT mode. used for conditioning the raw outputs
wire add_or_sub_mode; // This comes from the lookup table, and tells us if we are adding or subtracting. It is useful because things
// like the overflow and the carryout need to be disabled (set to zero) if we are not adding or subtracting

// LUT:
// mux index not needed in the top layer (only in the bitslices).
alucontrolLUT myLUT(
.muxindex (     ), 
.SUB_command (initial_carryin_for_subtraction), 
.aluCommand (command), 
.not_SLT_mode (not_SLT_mode), 
.add_or_sub_mode (add_or_sub_mode)); 



// creating the bitslices and tying them together
assign internal_carrys[0] = initial_carryin_for_subtraction; // only to make things more clear: I could have connected
// internal_carrys[0] straight to the LUT, but this more clearly indicates what information I am actually recieving from the LUT.
generate
genvar index;
	for (index = 0; index< `num_bits; index = index + 1) begin
		alu_Bitslice current_slice(.result_i (results_raw[index]), .A_i(operandA[index]), .B_i(operandB[index]), .carryin(internal_carrys[index]), .carryout(internal_carrys[index + 1]), .command(command));
	end
endgenerate

// conditioning results (giving the LUT the ability to set all the result bits to zero during LUT mode). Note that bit
// 0 is special, since it may also need to be returned to a 1.
`AND2(first_bit, results_raw[0], not_SLT_mode); // first case different.
`OR2(result[0], first_bit, AlessthanB); // if A is less than B and we are in SLT mode, then we want the result to be 1
generate // seperate generate because I want to handle the case index=0 seperately.
genvar index2;
	for (index2 = 0; index2< (`num_bits-1); index2 = index2 + 1) begin
		`AND2(result[index2+1], results_raw[index2+1], not_SLT_mode);
	end
endgenerate


// carryout is only used for addition, subtraction, and SLT(?). Not sure about the SLT.
// currently implemented as having no carryout in SLT mode.
`AND2(carryout, internal_carrys[`num_bits], add_or_sub_mode);

// calculating overflow
`XOR2(overflow_raw, internal_carrys[(`num_bits-1)], internal_carrys[`num_bits]);
`AND2(overflow, add_or_sub_mode, overflow_raw); // set overflow to 0 unless we are in a mode that uses overflows.

// calculating zero flag
assign #(`num_bits*10) zero = (~|(result)); // I could not get an addapable structural command to work here. Maybe some sort of generate loop that nors them all together,
// but preforming a bitwise nor was the only simple way I could get working that still adapts to different size alus.
// delay == 10* num inputs == 10* num_bits

// finally, decide whether or not to set the first bit to one (the wentireber to one) when in SLT mode
// to do this, we take A-B (done by the adders in the bitslices). There are then two possibilitys: either there is no overflow, in which case
// A<B is determined by having a negative MSB, and case two: there is an overflow. If there is an overflow, then a negative overflow means A<B.
// we check for a negative overflow by looking for MSB carryout == 1, and MSB carryin == 0.
wire check_overflow_case;
wire check_no_overflow_case;
wire AlessthanB_flag_raw; // this is one if A is less than B. it is considered raw because we don't want to use this value unless we are in SLT mode,
// which means it needs further conditioning.
wire not_carry_in;
`NOT(not_carry_in, internal_carrys[(`num_bits-1)]);
wire n_overflow; // no overflow, found by NOT(overflow_raw). Overflow_raw must be used because in SLT mode overflow is not used (enforced zero).
`NOT(n_overflow, overflow_raw);
wire SLT_mode; // the output from our LUT is inverted from what we want here (since the opposite signal is needed to zero all the other bits).
// rather than add another entry to the LUT, we just NOT the signal now.
`NOT(SLT_mode, not_SLT_mode);

`AND2(check_overflow_case, internal_carrys[`num_bits], not_carry_in); // if there was a carry in and a carry out to the MSB, then there was a 
// negative overflow, and A<B
`AND2(check_no_overflow_case, n_overflow, results_raw[(`num_bits-1)]); // if there is no overflow, then just check if the result is negative. do this by looking at the MSB.

`OR2(AlessthanB_flag_raw, check_overflow_case, check_no_overflow_case); // check if either A<B case occured

`AND2(AlessthanB, SLT_mode, AlessthanB_flag_raw); // we only want this flag active during SLT mode



endmodule





// tests functionality of a 32 bit alu
module aluTestBench;
reg [31:0]operandA;
reg [31:0]operandB;
reg [2:0] command;
wire [31:0]result;
wire carryout;
wire zero;
wire overflow;



alu alu32Bit(
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


command = 3'b010;
operandA=32'b01001001100010001011111000000100;operandB=32'b10111011001110101001101110001101;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | XOR", command, operandA, operandB, carryout, result, zero, overflow);
$display(""); // put in some blank space


command = 3'b100;
operandA=32'b00001000001100110000000011011110;operandB=32'b01111001111110010011001001001111;  #10000
$display("  %b   | %b  %b  |  %b   %b   |   %b    %b   | AND", command, operandA, operandB, carryout, result, zero, overflow);
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
