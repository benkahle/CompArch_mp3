module signExtend( clk, extSel, extend, extended);
//Extends an 8 bit input to a 32 bit output
input[15:0] extend;
input clk;
input extSel;
output[31:0] extended;

reg[31:0] extended;
wire[15:0] extend;

always @( posedge clk ) begin
    if (!extSel) begin 
    //Regular sign extension
        extended[31:0] <= { {16{extend[15]}}, extend[15:0] };
    end
    if (extSel) begin
    //If extSel is high, do an unsigned extension (all 0's)
        extended[31:0] <= { {16{1'b0}}, extend[15:0] };
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
    $display("Type       |    16-bit Input    |      32-bit Output                 |  extSel");
    $display("Signed     |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");
    #100;
    
    extend = -30;
    clk = 1;
    #100;
    clk = 0;
    $display("Signed     |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");
    #100

    extend = 7;
    clk = 1;
    #100;
    clk = 0;
    $display("Signed     |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");
    #100

    extend = 32768;
        clk = 1;
        #100;
        clk = 0;
    $display("Signed     |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");

    #100
    extSel = 1;
    extend = 32768;
    clk = 1;
    #100;
    clk = 0;
    $display("Unsigned   |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");
    #100;
    
    extend = -30;
    clk = 1;
    #100;
    clk = 0;
    $display("Unsigned   |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");
    #100

    extend = 7;
    clk = 1;
    #100;
    clk = 0;
    $display("Unsigned   |  %b  |  %b  |  %b", extend, extended, extSel);
    $display("");
    #100

    extend = 32768;
        clk = 1;
        #100;
        clk = 0;
    $display("Unsigned   |  %b  |  %b  |  %b", extend, extended, extSel);

    end

endmodule 