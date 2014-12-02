module signextend( clk, extend, extended );
//Extends an 8 bit input to a 32 bit output
input[15:0] extend;
input clk;
output[31:0] extended;

reg[31:0] extended;
wire[15:0] extend;

always @( posedge clk ) begin
    extended[31:0] <= { {16{extend[15]}}, extend[15:0] };
end

endmodule



module testsignextend;

    reg [15:0] extend;
    reg clk;

    wire [31:0] extended;

    signextend uut ( clk, extend, extended);
	

    initial begin
	clk = 0;
	extend = 0;
        #100; // 100 ns for global reset 

        extend = -30;
        clk = 1;
        #100;
        clk = 0;
	$display("Test Cases:");
	$display("16-bit input 1: %b", extend);
	$display("32-bit output 1: %b", extended);
	$display("");
	#100;
	extend = 40;
        clk = 1;
        #100;
        clk = 0;
	$display("16-bit input 2: %b", extend);
	$display("32-bit output 2: %b", extended);

    end

endmodule 
