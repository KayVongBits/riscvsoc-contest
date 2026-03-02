# 🚀 RISC-V CPU Core in Verilog

## 📖 项目简介
本项目由团队共同开发，旨在从零开始使用 Verilog 实现一个基础的 RISC-V 处理器核。
本项目主要用于学习和探索计算机体系结构、指令集架构 (ISA) 以及数字逻辑设计。

- **指令集架构 (ISA):** RV32I (基础整数指令集)
- **微架构:** 单周期 / 五级流水线 (根据你们的实际情况保留一个)
- **硬件描述语言:** Verilog (IEEE 1364-2001/2005)
- **开发与验证工具:** Xilinx Vivado / Icarus Verilog / ModelSim (根据你们的实际情况修改)

## 📂 目录结构
合理的目录结构有助于团队协作和代码管理：

├── docs/ # 项目文档，包含设计手册、RISC-V指令集PDF规范等
├── src/ # CPU 核心 Verilog 源代码 (ALU, 寄存器堆, 控制器等)
├── tb/ # Testbench 验证测试平台文件
├── scripts/ # 自动化仿真或综合的脚本 (如 .bat 或 .sh)
├── .gitignore # Git 忽略文件配置
└── README.md # 项目说明文档

## 🧠 架构概述
简要描述你们的 CPU 架构设计。例如，如果采用了经典的五级流水线，可以在这里列出：
1. **IF (Instruction Fetch):** 取指阶段
2. **ID (Instruction Decode):** 译码阶段
3. **EX (Execute):** 执行阶段
4. **MEM (Memory Access):** 访存阶段
5. **WB (Write Back):** 写回阶段

## 🛠️ 环境依赖
为了让团队成员能够顺利跑通项目，需要安装以下软件：
- **Git:** 用于版本控制和同步代码。
- **仿真工具:** 例如 Xilinx Vivado (用于综合和仿真) 

## 🚀 快速开始
新加入的团队成员请按照以下步骤配置本地环境：

1. **克隆仓库到本地:**
   ```bash
   git clone https://github.com/KayVongBits/riscvsoc-contest.git