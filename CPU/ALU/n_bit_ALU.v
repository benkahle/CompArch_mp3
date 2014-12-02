

`define num_bits 8'd32 // how many bits do you want your ALU to be? This module is fully parameterized by this define.

`define AND2 and #30 // 2 input NAND gate followed by 1 input inverter == 30 units of time
`define OR2 or #30 // 2 input NOR gate followed by 1 input inverter == 30 units of time
`define NOT not #10 // by definition, NOT gate has 1 input == 10 units of time
`define XOR2 xor #60 // ?? based on a circuit for a XOR gate using four NAND gates, where the worst case path propogates through
// three of them. All NAND gates are 2 input, so this makes a delay of 6 inputs == 60 units of time


// this ALU can preform the 8 basic operations requested by MP1.
module ALU(result, carryout, zero, overflow, operandA, operandB, command);
output[(`num_bits-1):0] result; 
output carryout; 
output zero; // this is one if the result is zero (every bit in the result bus is a zero)
output overflow;
input[(`num_bits-1):0] operandA; // inputs A and B. each are n-bits
input[(`num_bits-1):0] operandB;
input[2:0] command; // three bit command telling the ALU what to do. This gets parsed through a LUT


// this wire is used for connecting the carry chain for the adder
wire [`num_bits:0]internal_carrys; // one extra index (length n+1), since internal_carrys[0] is actually the initial carryin
wire [(`num_bits-1):0]results_raw; // the 'results' straight out of the bitslices. still needs some conditioning
// before they are ready to leave the ALU.
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
ALUcontrolLUT myLUT(
.muxindex (     ), 
.SUB_command (initial_carryin_for_subtraction), 
.ALUcommand (command), 
.not_SLT_mode (not_SLT_mode), 
.add_or_sub_mode (add_or_sub_mode)); 



// creating the bitslices and tying them together
assign internal_carrys[0] = initial_carryin_for_subtraction; // only to make things more clear: I could have connected
// internal_carrys[0] straight to the LUT, but this more clearly indicates what information I am actually recieving from the LUT.
generate
genvar index;
	for (index = 0; index< `num_bits; index = index + 1) begin
		ALU_Bitslice current_slice(.result_i (results_raw[index]), .A_i(operandA[index]), .B_i(operandB[index]), .carryin(internal_carrys[index]), .carryout(internal_carrys[index + 1]), .command(command));
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
// but preforming a bitwise nor was the only simple way I could get working that still adapts to different size ALUs.
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
