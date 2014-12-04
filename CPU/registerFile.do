vlog -reportprogress 300 -work work registerFile.v
vsim -voptargs="+acc" hw4testbenchharness

add wave -position insertpoint  \
sim:/hw4testbenchharness/readData1 \
sim:/hw4testbenchharness/readData2 \
sim:/hw4testbenchharness/writeData \
sim:/hw4testbenchharness/readRegister1 \
sim:/hw4testbenchharness/readRegister2 \
sim:/hw4testbenchharness/writeRegister \
sim:/hw4testbenchharness/regWrite \
sim:/hw4testbenchharness/clk \
sim:/hw4testbenchharness/beginTest \
sim:/hw4testbenchharness/endTest \
sim:/hw4testbenchharness/dutPassed
run -all

wave zoom full
