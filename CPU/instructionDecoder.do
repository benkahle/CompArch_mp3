vlog -reportprogress 300 -work work instructionDecoder.v
vsim -voptargs="+acc" testBench

run -all

wave zoom full