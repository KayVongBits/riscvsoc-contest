# ==========================================
# RISC-V SoC Simulation Makefile (Pure Tab)
# ==========================================

TOP_MODULE = riscv_top_tb
WAVE_FILE  = waveform.vcd

RTL_DIR = ../rtl
TB_DIR  = ../tb
SIM_DIR = sim
TB_FILE = $(TB_DIR)/$(TOP_MODULE).sv

.PHONY: all clean compile sim gui gtk surfer help

all: clean compile sim

compile:
	@echo.
	@echo ==================================================
	@echo  [1/2] 编译 RTL 与 Testbench 代码
	@echo  当前顶层模块: $(TOP_MODULE)
	@echo ==================================================
	-mkdir $(SIM_DIR) 2>nul
	cd $(SIM_DIR) && vlib work
	cd $(SIM_DIR) && vlog -sv $(RTL_DIR)/*.sv $(TB_FILE)

sim: compile
	@echo.
	@echo ==================================================
	@echo  [2/2] 正在运行命令行仿真 (CLI Mode)
	@echo  正在生成波形文件...
	@echo ==================================================
	cd $(SIM_DIR) && vsim -c -voptargs=+acc -do "run -all; quit" $(TOP_MODULE)

gui: compile
	@echo.
	@echo ==================================================
	@echo  启动 ModelSim GUI 图形界面
	@echo  正在加载模块: $(TOP_MODULE)
	@echo ==================================================
	cd $(SIM_DIR) && vsim -onfinish stop -voptargs=+acc -do "add wave -r /*; run -all" $(TOP_MODULE)

gtk:
	@echo.
	@echo ==================================================
	@echo  启动 GTKWave 查看波形
	@echo  文件路径: $(SIM_DIR)/$(WAVE_FILE)
	@echo ==================================================
	cmd /c start gtkwave $(SIM_DIR)/$(WAVE_FILE)

surfer:
	@echo.
	@echo ==================================================
	@echo  启动 Surfer 查看波形
	@echo  文件路径: $(SIM_DIR)/$(WAVE_FILE)
	@echo ==================================================
	cmd /c start surfer $(SIM_DIR)/$(WAVE_FILE)

clean:
	@echo.
	@echo ==================================================
	@echo  清理仿真生成的临时文件和波形...
	@echo ==================================================
	-rmdir /s /q $(SIM_DIR)\work 2>nul
	-del /q /f $(SIM_DIR)\transcript $(SIM_DIR)\*.vcd $(SIM_DIR)\*.wlf 2>nul

help:
	@echo.
	@echo ====================================================================
	@echo                   RISC-V SoC 仿真控制台帮助菜单
	@echo ====================================================================
	@echo  当前配置信息:
	@echo    - 顶层测试模块 : $(TOP_MODULE)
	@echo    - 目标波形文件 : $(WAVE_FILE)
	@echo.
	@echo  可用命令列表:
	@echo    mingw32-make          : (默认) 一键清理、编译并运行命令行仿真
	@echo    mingw32-make compile  : 仅编译 RTL 和 Testbench 文件
	@echo    mingw32-make sim      : 运行命令行仿真 (自动生成波形文件)
	@echo    mingw32-make gui      : 编译并打开 ModelSim GUI 图形界面
	@echo    mingw32-make gtk      : 使用 GTKWave 打开生成的 VCD 波形
	@echo    mingw32-make surfer   : 使用 Surfer 打开生成的 VCD 波形
	@echo    mingw32-make clean    : 删除 sim 目录下的所有编译产物和波形
	@echo    mingw32-make help     : 打印此帮助菜单
	@echo ====================================================================
	@echo.