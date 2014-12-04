vlog -reportprogress 300 -work work signExtend.v
vsim -voptargs="+acc" testSignExtend
add wave -position insertpoint \
sim:/testSignExtend/clk \
sim:/testSignExtend/extend \
sim:/testSignExtend/extended
run -all
wave zoom full
