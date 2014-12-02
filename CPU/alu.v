// define gates with delays
`define AND and
`define AND3 and
`define OR or
`define OR3 or
`define OR4 or
`define NAND nand
`define NOR nor
`define NOT not
`define XOR xor

`define ADD 3'd0
`define SUB 3'd1
`define XOR_c 3'd2
`define SLT 3'd3
`define AND_c 3'd4
`define NAND_c 3'd5
`define NOR_c 3'd6
`define OR_c 3'd7


//TODO: Validate the efficiency
module structuralFullAdder(out, carryout, a, b, carryin); 
output out, carryout; 
input a, b, carryin;

wire nA;
wire nB;
wire nC;
wire ABC;
wire AnBC;
wire ABnC;
wire nABC;
wire nAnBC;
wire AnBnC;
wire nABnC;

`NOT notA(nA, a);
`NOT notB(nB, b);
`NOT notC(nC, carryin);

`AND3 Co0(nABC, nA, b, carryin);
`AND3 Co1(ABC, a, b, carryin);
`AND3 Co2(AnBC, a, nB, carryin);
`AND3 Co3(ABnC, a, b, nC);
`OR4 Co(carryout, nABC, ABC, AnBC, ABnC);

`AND3 S0(nAnBC, nA, nB, carryin);
`AND3 S1(AnBnC, a, nB, nC);
`AND3 S2(nABnC, nA, b, nC);
`OR4 S(out, ABC, nAnBC, AnBnC, nABnC);
endmodule

module adderSubtractor32bit(sum, carryout, overflow, a, b, subtractEnable); 
output[31:0] sum; 
output carryout; 
output overflow; 
input[31:0] a; 
input[31:0] b; 
input subtractEnable; 
wire[30:0] carrythrough; 
wire[31:0] newB; 
`XOR flip0(newB[0], subtractEnable, b[0]); 
structuralFullAdder adder0(sum[0], carrythrough[0], a[0], newB[0], subtractEnable); 
generate 
genvar index;
  for (index = 1; index<31; index = index + 1) begin
    `XOR flip(newB[index], subtractEnable, b[index]);
    structuralFullAdder adder(sum[index], carrythrough[index], a[index], newB[index], carrythrough[index-1]);
  end
endgenerate
`XOR flip32(newB[31], subtractEnable, b[31]);
structuralFullAdder adder32(sum[31], carryout, a[31], newB[31], carrythrough[30]);

`XOR overflowCalc(overflow, carrythrough[30], carryout); 
endmodule

module testAddSub;
reg[31:0] a, b;
reg subtractEnable;
wire[31:0] sum;

wire carryout;
wire overflow;

adderSubtractor32bit addsub(sum, carryout, overflow, a, b, subtractEnable);

initial begin
a=4'h1;b=4'h0;subtractEnable=0; #8000
$display("     %b      %b        %b(ADD) |        %b            %b       |       0                0      0     0", a, b, sum, carryout, overflow);
a=4'h1;b=4'h1;subtractEnable=1; #8000
$display("     %b      %b        %b(SUB) |        %b            %b       |       0                0      0     0", a, b, sum, carryout, overflow);
end 
endmodule


//TODO: Determine necessity of inner loop 
//This module does 32 bit addition, subtraction, or SLT. For SLT, the MSB of the result will be the true/false data.
module adderSubtractorSLT32bit(sumOrSLT, carryout, overflow, a, b, subtractEnable, sltEnable); 
output[31:0] sumOrSLT; 
output carryout; 
output overflow; 
input[31:0] a; 
input[31:0] b; 
input subtractEnable; 
input sltEnable; 
wire[31:0] adderOutput; 
wire adderOverflow; 
wire n_sltEnable; 
`NOT notslt(n_sltEnable, sltEnable); 
adderSubtractor32bit adder(adderOutput, carryout, overflow, a, b, subtractEnable); 
//This loop sets all non-MSB bits to zero if the sltEnable is set. This may not be necessary if only the MSB is read during SLT mode.
generate
genvar index;
  for (index = 0; index<31; index = index + 1) begin
    `AND andGate(sumOrSLT[index], adderOutput[index], n_sltEnable);
  end
endgenerate
wire overflowAndsltEnable;
`AND oAndSLTE(overflowAndsltEnable, overflow, sltEnable); 
`XOR msbOut(sumOrSLT[31], overflowAndsltEnable, adderOutput[31]); 
endmodule

//TODO: Validate efficiency
module structuralMultiplexer(out, muxindex, in0,in1,in2,in3);
output[31:0] out;
input[1:0] muxindex;
input[31:0] in0, in1, in2, in3;

wire nA0;
wire nA1;
wire nA0andnA1;
wire A0andnA1;
wire nA0andA1;
wire A0andA1;
wire[31:0] out0;
wire[31:0] out1;
wire[31:0] out2;
wire[31:0] out3;

`NOT n0(nA0, muxindex[0]);
`NOT n1(nA1, muxindex[1]);

`AND i0(nA0andnA1, nA0, nA1);
`AND i1(A0andnA1, muxindex[0], nA1);
`AND i2(nA0andA1, nA0, muxindex[1]);
`AND i3(A0andA1, muxindex[0], muxindex[1]);

generate
genvar index;
  for (index = 0; index<32; index = index + 1) begin
    `AND o0(out0[index], nA0andnA1, in0[index]);
    `AND o1(out1[index], A0andnA1, in1[index]);
    `AND o2(out2[index], nA0andA1, in2[index]);
    `AND o3(out3[index], A0andA1, in3[index]);
    `OR4 outOr(out[index], out0[index], out1[index], out2[index], out3[index]);
  end
endgenerate
endmodule

module andNand(result, a, b, altEnable);
output[31:0] result;
input[31:0] a;
input[31:0] b;
input altEnable;
wire[31:0] nandState;
generate genvar index;
  for (index = 0; index<32; index = index + 1) begin
    `NAND (nandState[index], a[index], b[index]);
    `XOR (result[index], nandState[index], altEnable);
  end
endgenerate
endmodule

module orNor(result, a, b, altEnable);
output[31:0] result;
input[31:0] a;
input[31:0] b;
input altEnable;
wire[31:0] norState;
generate
genvar index;
  for (index = 0; index<32; index = index + 1) begin
    `NOR (norState[index], a[index], b[index]);
    `XOR (result[index], norState[index], altEnable);
  end
endgenerate
endmodule

module ALUcontrolLUT(muxindex, altEnable, sltEnable, ALUcommand);
output reg[1:0] muxindex;
output reg altEnable;
output reg sltEnable;
input[2:0] ALUcommand;
always @(ALUcommand) begin
  case (ALUcommand)
    `ADD: begin muxindex = 0; altEnable=0; sltEnable = 0; end
    `SUB: begin muxindex = 0; altEnable=1; sltEnable = 0; end
    `SLT: begin muxindex = 0; altEnable=1; sltEnable = 1; end
    `XOR_c: begin muxindex = 1; altEnable=0; sltEnable = 0; end
    `AND_c: begin muxindex = 2; altEnable=1; sltEnable = 0; end
    `NAND_c: begin muxindex = 2; altEnable=0; sltEnable = 0; end
    `NOR_c: begin muxindex = 3; altEnable=0; sltEnable = 0; end
    `OR_c: begin muxindex = 3; altEnable=1; sltEnable = 0; end
  endcase
end 
endmodule

module bitwiseXOR(xorOut, a, b);
output[31:0] xorOut;
input[31:0] a;
input[31:0] b;
generate
genvar index;
  for (index = 0; index<32; index = index + 1) begin
    `XOR (xorOut[index], a[index], b[index]);
  end
endgenerate
endmodule

module ALU(result, carryout, zero, overflow, a, b, command);
output[31:0] result;
output carryout;
output zero;
output overflow;
input[31:0] a;
input[31:0] b;
input[2:0] command;
wire[1:0] muxindex;
wire addsubsltOverflow;
wire addsubsltCarryout;

wire[31:0] sumOrSLT;
wire[31:0] xorOut;
wire[31:0] andNandOut;
wire[31:0] orNorOut;
//Set the zero output to always output zero without memory. TODO: improve?
wire notCommand;
`NOT (notCommand, command);
`AND (zero, command, notCommand);

ALUcontrolLUT controlLUT(muxindex, altEnable, sltEnable, command); 
//Mux Input Modules 
adderSubtractorSLT32bit AddSubSLT(sumOrSLT, carryout, overflow, a, b, altEnable, sltEnable);

//Define XOR, AND/NAND, and OR/NOR outputs:
bitwiseXOR XOR(xorOut, a, b);
andNand AndNand(andNandOut, a, b, altEnable); 
orNor OrNor(orNorOut, a, b, altEnable);

//Select the proper output based on Mux Input 
structuralMultiplexer mux(result, muxindex, sumOrSLT, xorOut, andNandOut, orNorOut); 
endmodule

//TODO: TEST EVERYTHING
module testALU;
reg[31:0] a, b;
reg[2:0] command;

wire [31:0] result;
wire carryout;
wire zero;
wire overflow;

ALU alu(result, carryout, zero, overflow, a, b, command);

initial begin
$display("Add Tests");
$display("               a                                          b                      Command    |                  Result                       Carryout Zero Overflow| Expected Result    Carryout Zero Overflow");
a=32'b00010000000000000000000000000000;b=32'b11110000000000000000000000000000;command=`ADD; #8000
$display("     %b      %b        %b(ADD) |        %b            %b      %b    %b    |       0000...0000    1      0     0", a, b, command, result, carryout, zero, overflow);
a=32'b00000000000000000000000000000010;b=32'b00000000000000000000000000000001;command=`ADD; #8000
$display("     %b      %b        %b(ADD) |        %b            %b      %b    %b    |       0000...0011    0      0     0", a, b, command, result, carryout, zero, overflow);
a=32'b10000000000000000000000000000000;b=32'b10000000000000000000000000000000;command=`ADD; #8000
$display("     %b      %b        %b(ADD) |        %b            %b      %b    %b    |       0000...0000    1      0     1", a, b, command, result, carryout, zero, overflow);
a=32'b01010000000000000000000000000000;b=32'b01010000000000000000000000000000;command=`ADD; #8000
$display("     %b      %b        %b(ADD) |        %b            %b      %b    %b    |       1010...0000    0      0     1", a, b, command, result, carryout, zero, overflow);

$display("Sub Tests");
$display("5-2=3, standard subtraction");
a=32'b00000000000000000000000000000101;b=32'b00000000000000000000000000000010;command=`SUB; #8000
$display("     %b      %b        %b(SUB) |        %b            %b      %b    %b    |      0000....0011   1      0     0", a, b, command, result, carryout, zero, overflow);
$display("5-(-2)=7, subtraction of a negative number, ");
a=32'b00000000000000000000000000000101;b=32'b11111111111111111111111111111110;command=`SUB; #8000
$display("     %b      %b        %b(SUB) |        %b            %b      %b    %b    |      0000....0111   0      0     0", a, b, command, result, carryout, zero, overflow);

$display("SLT Tests");
$display("5<2?, expect false");
a=32'b00000000000000000000000000000011;b=32'b00000000000000000000000000000010;command=`SLT; #8000
$display("     %b      %b        %b(SLT) |        %b            %b      %b    %b    |      0000....0000   1      0     0", a, b, command, result, carryout, zero, overflow);
$display("-5<2?, expect true");
a=32'b11111111111111111111111111111011;b=32'b00000000000000000000000000000010;command=`SLT; #8000
$display("     %b      %b        %b(SLT) |        %b            %b      %b    %b    |      1000....0000   1      0     0", a, b, command, result, carryout, zero, overflow);


end
endmodule