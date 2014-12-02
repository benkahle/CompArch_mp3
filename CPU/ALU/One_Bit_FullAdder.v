

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

