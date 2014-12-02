
// added the 'OP' because some of these names are already gates
`define OP_ADD 3'd0
`define OP_SUB 3'd1
`define OP_XOR 3'd2
`define OP_SLT 3'd3
`define OP_AND 3'd4
`define OP_NAND 3'd5
`define OP_NOR 3'd6
`define OP_OR 3'd7

// this LUT, source code provided largely by Eric, takes a three bit command (ALUcommand),
// which determines what operation needs to be preformed, and returns all the neccessary
// control lines to make this happen. 
module ALUcontrolLUT(muxindex, SUB_command, ALUcommand , not_SLT_mode, add_or_sub_mode);
output reg not_SLT_mode; // used to set all outputs to zero during SLT mode
output reg add_or_sub_mode; // used to disable the carryout during any mode but add and subtract.
output reg[2:0] muxindex; // controls the MUX at the end of each bitslice
output reg SUB_command; // are we subtracting or not?
input[2:0] ALUcommand; // the input command

// here is the actual LUT, in behaviorial verilog
always @(ALUcommand) begin 
	case (ALUcommand)
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




