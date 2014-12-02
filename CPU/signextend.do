vlog -reportprogress 300 -work work signextend.v
vsim -voptargs="+acc" testsignextend
add wave -position insertpoint \
sim:/testsignextend/clk \
sim:/testsignextend/extend \
sim:/testsignextend/extended
run -all
wave zoom full