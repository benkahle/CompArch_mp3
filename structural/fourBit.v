//////////////////////////////////////////
// 4-bit adder from 1-bit adder chain
// Ruby Spring
// Sept. 2014
//////////////////////////////////////////

`define AND and #50
`define XOR xor #50
`define OR or #50

module fullAdder(S, Cout, A, B, Cin);
    output S, Cout;
    input A, B, Cin;
    wire XorAB;
    wire andAB;
    wire andCXorAB;
    `XOR AxorB(XorAB, A, B);
    `XOR ABxorC(S, XorAB, Cin);
    `AND AandB(andAB, A, B);
    `AND CandAxorB(andCXorAB, XorAB, Cin);
    `OR AandBorCandAxorB(Cout, andAB, andCXorAB);
endmodule
module multiStage(S, Cout, Over, A, B);
    output[3:0] S;
    output Cout, Over;
    input[3:0] A;
    input[3:0] B;

    wire Cout0, Cout1, Cin;

    `XOR CxorC(Over, Cout, Cout2);

    assign Cin = 0;
    fullAdder s0(S[0], Cout0, A[0], B[0], Cin);
    fullAdder s1(S[1], Cout1, A[1], B[1], Cout);
    fullAdder s2(S[2], Cout2, A[2], B[2], Cout1);
    fullAdder s3(S[3], Cout, A[3], B[3], Cout2);
endmodule
module mp0(input [7:0] sw, output [7:0] led);
	// Input A is the first 4 switches ? sw[0:3]
	// Input B is the second 4 switches ? sw[4:7]
	// The sum is displayed on the first 4 LEDs ? led[3:0]
	// The carry out is the 5th LED ? led[4]
	// The overflow detect is shown on the last LED ? led[7]
	multiStage adder(led[3:0],led[4],led[7],sw[3:0],sw[7:4]);
endmodule
module testMultiStage;
    wire[3:0] S;
    wire Cout, Over; 
    reg[3:0] A;
    reg[3:0] B;
    multiStage uut (S, Cout, Over, A, B);
initial begin
$display("A     B     |  Cout Sum   Over |  expected_Over");
A=4'b0000; B=4'b0000; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0000; B=4'b0001; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0010; B=4'b0001; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0010; B=4'b0010; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0011; B=4'b0001; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0011; B=4'b0010; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0011; B=4'b0011; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0011; B=4'b0101; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0011; B=4'b0111; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 1);
A=4'b0100; B=4'b0001; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0100; B=4'b0010; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0100; B=4'b0011; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b0100; B=4'b0100; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 1);
A=4'b0100; B=4'b0101; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 1);
A=4'b1000; B=4'b0100; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1000; B=4'b0101; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1000; B=4'b0110; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1000; B=4'b0111; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1000; B=4'b1000; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 1);
A=4'b1111; B=4'b0001; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b0010; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b0011; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b0100; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b0101; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b0110; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b0111; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b1000; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
A=4'b1111; B=4'b1111; #2000 
$display("%b  %b  |  %b    %b  %b ", A, B, Cout, S, Over, 0);
end
endmodule
