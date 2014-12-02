module behavioralFullAdder(sum, carryout, a, b, carryin);
output sum, carryout;
input a, b, carryin;
assign {carryout, sum}=a+b+carryin;
endmodule

module structuralFullAdder(out, carryout, a, b, carryin);
output out, carryout;
input a, b, carryin;
 // Your Code Here
endmodule

module testFullAdder;
reg a, b, carryin;
wire sum, carryout;
behavioralFullAdder adder (sum, carryout, a, b, carryin);

initial begin
// Your Code Here
end
endmodule
