irun -access +rwc \
-linedebug \
CPU.v \
CP0.v \
CACHE.v \
STOREBUFFER.v \
CTRL.v \
DATARAM.v \
DIV.v \
MUL.v \
EX.v \
EX2MEM.v \
HILO.v \
ID.v \
ID2EX.v \
IF2ID.v \
INSTROM.v \
MEM.v \
MEM2WB.v \
PC.v \
REGFILE.v \
IWISHBONE.v \
DWISHBONE.v \
SOPC.v \
tb.v \
./wishbone/wb_conmax_arb.v \
./wishbone/wb_conmax_master_if.v \
./wishbone/wb_conmax_msel.v \
./wishbone/wb_conmax_pri_dec.v \
./wishbone/wb_conmax_pri_enc.v \
./wishbone/wb_conmax_rf.v \
./wishbone/wb_conmax_slave_if.v \
./wishbone/wb_conmax_top.v \
-timescale 1ns/1ns -input ncsim.tcl

