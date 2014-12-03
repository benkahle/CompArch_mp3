vlog -reportprogress 300 -work work dataMemory.v
vsim -voptargs="+acc" testBenchHarness

add wave -position insertpoint  \
sim:/testBenchHarness/clk \
sim:/testBenchHarness/regWE \
sim:/testBenchHarness/addr \
sim:/testBenchHarness/dataIn \
sim:/testBenchHarness/dataOut \
sim:/testBenchHarness/beginTest 

run -all

wave zoom full