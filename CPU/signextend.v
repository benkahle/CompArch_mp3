module signextend( clk, extend, extended );
//Extends an 8 bit input to a 32 bit output
input[7:0] extend;
input clk;
output[31:0] extended;

reg[31:0] extended;
wire[7:0] extend;

always @( posedge clk ) begin
    extended[31:0] <= { {24{extend[7]}}, extend[7:0] };
end

endmodule



module testsignextend;

    reg [7:0] extend;
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
	
	$display("Input 1: %b", extend);
	$display("Extended output 1: %b", extended);
	#100;
	extend = 40;
        clk = 1;
        #100;
        clk = 0;
	$display("Input 2: %b", extend);
	$display("Extended output 2: %b", extended);

    end

endmodule 
