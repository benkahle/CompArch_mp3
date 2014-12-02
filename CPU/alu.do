vlog -reportprogress 300 -work work alu.v
vsim -voptargs="+acc" testALU
add wave -position insertpoint \
sim:/testALU/a \
sim:/testALU/b \
sim:/testALU/carryout \
sim:/testALU/result \
sim:/testALU/overflow \
sim:/testALU/zero \
sim:/testALU/command 
run -all
wave zoom full