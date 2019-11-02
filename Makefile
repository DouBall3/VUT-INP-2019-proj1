BASE = ../../../
FCMAKE = C:/Program Files/FITkit/bin/fcmake.exe
FKFLASH = C:/Program Files/FITkit/bin/fkflash.exe
FKTERM = C:/Program Files/FITkit/bin/fkterm.exe
FKTEST = C:/Program Files/FITkit/bin/fktest.exe
PROJECT = project.xml
OUTPUTPREFIX = project
FPGACHIP = xc3s50
FPGASPEEDGRADE = 4
FPGAPACKAGE = pq208

all: dependencycheck build/project_f1xx.hex build/project_f2xx.hex build/project.bin

#MCU part
#=====================================================================
HEXFILE_F1XX = build/project_f1xx.hex
HEXFILE_F2XX = build/project_f2xx.hex

build/mcu/main_f1xx.o: mcu/main.c
	$(comp_tpl_f1xx)

build/mcu/main_f2xx.o: mcu/main.c
	$(comp_tpl_f2xx)

OBJFILES_F1XX = build/mcu/main_f1xx.o
OBJFILES_F2XX = build/mcu/main_f2xx.o

#FPGA part
#=====================================================================
FPGAUCF = fpga/ledc8x8.ucf
BINFILE = build/project.bin
HDLFILES  = fpga/ledc8x8.vhd

build/project.bin: build/fpga/project.par.ncd build/fpga/project.pcf

include $(BASE)/base/Makefile.inc
