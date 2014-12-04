vlog -reportprogress 300 -work work instructionDecoder.v
vsim -voptargs="+acc" testInstructionDecoder

run -all

wave zoom full