module signExtend( clk, extSel, extend, extended);
//Extends an 8 bit input to a 32 bit output
input[15:0] extend;
input clk;
input extSel;
output[31:0] extended;

reg[31:0] extended;
wire[15:0] extend;

always @(*) begin
    if (!extSel) begin 
    //Regular sign extension
        extended[31:0] = { {16{extend[15]}}, extend[15:0] };
    end
    else begin
    //If extSel is high, do an unsigned extension (all 0's)
        extended[31:0] = { {16{1'b0}}, extend[15:0] };
    end

end

endmodule



module testSignExtend;

    reg [15:0] extend;
    reg clk;
    reg extSel;

    wire [31:0] extended;

    signExtend uut ( clk, extSel, extend, extended);
	

    initial begin
	clk = 0;
	extend = 0;
    extSel = 0;
        #100; // 100 ns for global reset 

        extend = -8;
        clk = 1;
        #100;
        clk = 0;
	$display("Test Cases:");
	$display("16-bit input -d8: %b", extend);
	$display("32-bit output -d8: %b", extended);
	$display("");
	#100;
	
	extend = -30;
	clk = 1;
	#100;
	clk = 0;
	$display("16-bit input -d30: %b", extend);
	$display("32-bit output -d30: %b", extended);
	$display("");
	#100

	extend = 7;
	clk = 1;
	#100;
	clk = 0;
	$display("16-bit input d7: %b", extend);
	$display("32-bit output d7: %b", extended);
	$display("");
	#100

	extend = 32768;
        clk = 1;
        #100;
        clk = 0;
	$display("16-bit input d32768: %b", extend);
	$display("32-bit output d32768: %b", extended);

    #100
    extSel = 1;
    $display("Unsigned Test Cases:");
    $display("16-bit input -d8: %b", extend);
    $display("32-bit output -d8: %b", extended);
    $display("");
    #100;
    
    extend = -30;
    clk = 1;
    #100;
    clk = 0;
    $display("16-bit input -d30: %b", extend);
    $display("32-bit output -d30: %b", extended);
    $display("");
    #100

    extend = 7;
    clk = 1;
    #100;
    clk = 0;
    $display("16-bit input d7: %b", extend);
    $display("32-bit output d7: %b", extended);
    $display("");
    #100

    extend = 32768;
        clk = 1;
        #100;
        clk = 0;
    $display("16-bit input d32768: %b", extend);
    $display("32-bit output d32768: %b", extended);

    end

endmodule 
