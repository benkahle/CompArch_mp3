vlog -reportprogress 300 -work work dataMemory.v
vsim -voptargs="+acc" testBench

run -all

wave zoom full