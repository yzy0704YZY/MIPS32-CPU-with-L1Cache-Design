# Cadence Encounter(R) RTL Compiler
#   version v12.10-s043_1 (64-bit) built Aug 12 2013
#
# Run with the following arguments:
#   -logfile rc.log
#   -cmdfile rc.cmd

set_attribute hdl_search_path  /home/ziyin/CPU/CPU/
set_attribute lib_search_path  /home/ziyin/CPU/CPU/lib/
set_attribute library gscl45nm.lib
read_hdl  -v2001 {CPU.v CP0.v CTRL.v DIV.v MUL.v HILO.v EX.v EX2MEM.v ID.v ID2EX.v IF2ID.v MEM.v MEM2WB.v PC.v REGFILE.v CACHE.v STOREBUFFER.v IWISHBONE.v DWISHBONE.v}
elaborate
synthesize -to_mapped
write_hdl>> CPU.vg
gui_show
