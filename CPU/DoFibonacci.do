vlog -reportprogress 300 -work work cpu.v instructionMemory.v \
instructionDecoder.v registerFile.v ALU.v dataMemory.v signextend.v
vsim -voptargs="+acc" testCpu
add wave -position insertpoint \
sim:/testCpu/clk \
sim:/testCpu/cpu/pc \
sim:/testCpu/cpu/mpcs/pcSrc \
sim:/testCpu/cpu/pca/pc \
sim:/testCpu/cpu/pca/pcPlus4 \
sim:/testCpu/cpu/newPc \
sim:/testCpu/cpu/id/instruction \
sim:/testCpu/cpu/id/pcSrc \
sim:/testCpu/cpu/im/mem \
sim:/testCpu/cpu/dm/mem

run 450

wave zoom full