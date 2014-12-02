



`define AND2 and #30 // 2 input NAND gate followed by 1 input inverter == 30 units of time
`define OR2 or #30 // 2 input NOR gate followed by 1 input inverter == 30 units of time
`define NOT not #10 // by definition, NOT gate has 1 input == 10 units of time
`define XOR2 xor #60 // ?? based on a circuit for a XOR gate using four NAND gates, where the worst case path propogates through
// three of them. All NAND gates are 2 input, so this makes a delay of 6 inputs == 60 units of time
`define NAND2 nand #20 // basic 2 input NAND
`define NOR2 nor #20 // basic 2 input NOR

// this module serves to calculate one bit of a ALU, given a command to preform one of eight different
// arithmatic operations.
module ALU_Bitslice(result_i, A_i, B_i, carryin, carryout, command);

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

ALUcontrolLUT myLUT (
.muxindex (mux_command), 
.SUB_command (SUB_command), 
.ALUcommand (command),
.not_SLT_mode (          ), // not used at the bitslice level, only for the full ALU
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
