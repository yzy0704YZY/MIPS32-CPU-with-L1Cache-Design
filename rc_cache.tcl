# Cadence Encounter(R) RTL Compiler
#   version v12.10-s043_1 (64-bit) built Aug 12 2013
#
# Run with the following arguments:
#   -logfile rc.log
#   -cmdfile rc.cmd

set_attribute hdl_search_path  /home/ziyin/VERILOG/CPU/
set_attribute lib_search_path  /home/ziyin/VERILOG/CPU/lib/
set_attribute library gscl45nm.lib
read_hdl  -v2001 {CACHETOP.v CACHE.v STOREBUFFER.v}
elaborate
synthesize -to_mapped
write_hdl>> CACHE.vg
gui_show
