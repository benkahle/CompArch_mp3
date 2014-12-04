module cpu();

	#5 clk=1; #5 clk=0; #set clock to 10Mhz

    instructionMemory(#PCout);
    
    instructionDecoder(#instruction);

    registerFile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);

    aluSourceB(ReadData2, #ReadData2out, #SignExtendOut, #aluSourceBSelect);

    alu(#ReadData1, #ReadData2);

endmodule
module aluSourceB(ReadData2in, #SignExtendOut, #aluSourceBSelect);
    input[31:0] ReadData2;
    input #aluSourceBSelect;
    output[31:0] #SignExtendOut;

