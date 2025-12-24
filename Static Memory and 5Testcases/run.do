vlib work
vlog tb.v 
vsim -novopt -suppress 12110 tb +testcase=test_fd_wr_rd
add wave -position -insertpoint sim:/tb/dut/*
run -all
