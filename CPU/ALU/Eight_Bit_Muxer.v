
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


