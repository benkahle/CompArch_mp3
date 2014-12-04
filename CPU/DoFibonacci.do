vlog -reportprogress 300 -work work cpu.v instructionMemory.v \
instructionDecoder.v registerFile.v ALU.v dataMemory.v signextend.v
vsim -voptargs="+acc" testCpu
add wave -position insertpoint \
sim:/testCpu/clk 

run 10000

wave zoom full