# ==========================================
# RISC-V SoC Simulation Makefile (Pure Tab)
# ==========================================

TOP_MODULE = riscv_top_tb

RTL_DIR = ../rtl
TB_DIR  = ../tb
SIM_DIR = sim
TB_FILE = $(TB_DIR)/$(TOP_MODULE).sv

.PHONY: all clean compile sim help

# 默认目标 (敲 make)：一键清理、编译，并直接打开全功能图形界面跑完波形
all: clean sim

compile:
	@echo.
	@echo =========================================================
	@echo   [STEP 1/2] 编译 RTL 与 Testbench 代码
	@echo =========================================================
	@echo   * 顶层测试模块 : $(TOP_MODULE)
	@echo   * 正在建立工作库并编译 SystemVerilog 源码...
	-mkdir $(SIM_DIR) 2>nul
	cd $(SIM_DIR) && vlib work
	cd $(SIM_DIR) && vlog -sv $(RTL_DIR)/*.sv $(TB_FILE)

# sim 扶正为主功能：直接启动全功能图形界面，自动添加所有波形并运行到底
sim: compile
	@echo.
	@echo =========================================================
	@echo   [STEP 2/2] 启动 ModelSim 实时调试模式 (GUI)
	@echo =========================================================
	@echo   * 正在自动加载全景信号并运行仿真...
	@echo   * [提示] 查看底层存储器(ROM/RAM)请使用顶部菜单: 
	@echo   * View -^> Memory List
	@echo =========================================================
	cd $(SIM_DIR) && vsim -onfinish stop -voptargs="+acc" -do "log -r /*; run -all" $(TOP_MODULE)

clean:
	@echo.
	@echo =========================================================
	@echo   [CLEAN] 清理仿真环境...
	@echo =========================================================
	@echo   * 正在删除旧的编译库及波形残留文件...
	-rmdir /s /q $(SIM_DIR)\work 2>nul
	-del /q /f $(SIM_DIR)\transcript $(SIM_DIR)\*.vcd $(SIM_DIR)\*.wlf 2>nul
	@echo   * 环境清理完毕！

help:
	@echo.
	@echo *********************************************************
	@echo * RISC-V SoC 仿真控制台菜单                *
	@echo *********************************************************
	@echo.
	@echo   当前配置信息:
	@echo     - 顶层模块 : $(TOP_MODULE)
	@echo.
	@echo   可用命令列表:
	@echo     make          : (默认) 一键清理、编译，并打开图形界面跑完波形
	@echo     make compile  : 仅编译 RTL 和 Testbench 代码
	@echo     make sim      : 编译并打开图形界面 (自动添加波形并运行)
	@echo     make clean    : 深度删除 sim 目录下的所有编译产物
	@echo     make help     : 打印此帮助菜单
	@echo.
	@echo *********************************************************
	@echo.