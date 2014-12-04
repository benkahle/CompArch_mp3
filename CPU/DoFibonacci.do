vlog -reportprogress 300 -work work cpu.v instructionMemory.v \
instructionDecoder.v registerFile.v ALU.v dataMemory.v signextend.v
vsim -voptargs="+acc" testCpu
add wave -position insertpoint \
sim:/testCpu/clk \
sim:/testCpu/cpu/pc \
sim:/testCpu/cpu/id/instruction \
sim:/testCpu/cpu/id/rs \
sim:/testCpu/cpu/id/rt \
sim:/testCpu/cpu/id/rd \
sim:/testCpu/cpu/id/imm \
sim:/testCpu/cpu/id/pcSrc \
sim:/testCpu/cpu/jAbs \
sim:/testCpu/cpu/im/mem \
sim:/testCpu/cpu/dm/mem

run 4000

wave zoom full