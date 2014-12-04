vlog -reportprogress 300 -work work ALU.v
vsim -voptargs="+acc" Tester_ThirtyTwo_Bit_ALU
add wave -position insertpoint \
sim:/Tester_ThirtyTwo_Bit_ALU/operandA \
sim:/Tester_ThirtyTwo_Bit_ALU/operandB \
sim:/Tester_ThirtyTwo_Bit_ALU/command \
sim:/Tester_ThirtyTwo_Bit_ALU/result \
sim:/Tester_ThirtyTwo_Bit_ALU/carryout \
sim:/Tester_ThirtyTwo_Bit_ALU/zero \
sim:/Tester_ThirtyTwo_Bit_ALU/overflow
run -all
wave zoom full