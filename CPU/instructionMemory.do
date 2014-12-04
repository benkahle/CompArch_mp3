vlog -reportprogress 300 -work work instructionMemory.v
vsim -voptargs="+acc" testBench

run 1400

wave zoom full