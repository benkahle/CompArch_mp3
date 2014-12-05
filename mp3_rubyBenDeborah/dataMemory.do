vlog -reportprogress 300 -work work dataMemory.v
vsim -voptargs="+acc" testDataMem

run -all

wave zoom full