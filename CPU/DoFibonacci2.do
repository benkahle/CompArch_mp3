vlog -reportprogress 300 -work work cpu2.v instructionMemory.v \
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
sim:/testCpu/cpu/full_imm \
sim:/testCpu/cpu/id/pcSrc \
sim:/testCpu/cpu/pcPlus4 \
sim:/testCpu/cpu/id/writebackSrc \
sim:/testCpu/cpu/jAbs \
sim:/testCpu/cpu/id/aluCommand \
sim:/testCpu/cpu/id/aluSrcB \
sim:/testCpu/cpu/aluOut \
sim:/testCpu/cpu/aluZero \
sim:/testCpu/cpu/ReadData1 \
sim:/testCpu/cpu/ReadData2 \
sim:/testCpu/cpu/rf/readRegister1 \
sim:/testCpu/cpu/rf/readRegister2 \
sim:/testCpu/cpu/rf/Q \
sim:/testCpu/cpu/WriteData \
sim:/testCpu/cpu/B

run 3000

wave zoom full