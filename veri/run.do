if [file exists "work"] {file delete -force -- work}
vlib work
vmap work work
vlog -f filelist.f
vsim -voptargs=+acc riscv_top_tb
add wave riscv_top_tb/u_riscv_top/*
set NoQuitOnFinish 1
onbreak {resume}
#log /* -r
#do wave.do
run 100us