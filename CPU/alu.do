vlog -reportprogress 300 -work work alu.v
vsim -voptargs="+acc" aluTestBench
add wave -position insertpoint \
sim:/aluTestBench/operandA \
sim:/aluTestBench/operandB \
sim:/aluTestBench/command \
sim:/aluTestBench/result \
sim:/aluTestBench/carryout \
sim:/aluTestBench/zero \
sim:/aluTestBench/overflow
run 450
wave zoom full
