@echo off
setlocal

REM ==========================================
REM 1. 配置区：在这里修改你的汇编文件名（不加后缀）
REM ==========================================
set FILE_NAME=test_s

echo === RISC-V 编译与格式转换工具 ===
echo 正在处理: %FILE_NAME%.S

REM ==========================================
REM 2. 环境准备：在上一级目录创建 txt 和 hex 文件夹
REM ==========================================
if not exist "..\txt" (
    mkdir "..\txt"
    echo [+] 创建文件夹: ..\txt\
)
if not exist "..\txt\hex" (
    mkdir "..\txt\hex"
    echo [+] 创建文件夹: ..\txt\hex\
)

REM ==========================================
REM 3. 编译阶段：.S -> .elf
REM ==========================================
echo [1/2] 正在编译汇编文件...
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Ttext 0x0 -nostdlib -o %FILE_NAME%.elf %FILE_NAME%.S
if %errorlevel% neq 0 (
    echo [错误] 编译失败！请检查你的汇编代码语法。
    pause
    exit /b %errorlevel%
)

REM ==========================================
REM 4. 转换阶段：直接生成 Hex 并复制为 Txt
REM ==========================================
echo [2/2] 正在生成 Hex 和 Txt 格式机器码...
REM 直接将 elf 输出为按 32位(4字节) 排列的 verilog hex 格式，存入 ../txt/hex/
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 --reverse-bytes=4 -j .text %FILE_NAME%.elf "..\txt\hex\%FILE_NAME%.hex"
if %errorlevel% neq 0 (
    echo [错误] 生成 Hex 文件失败！
    pause
    exit /b %errorlevel%
)

REM 将生成的 hex 文件复制一份并重命名为 .txt，存入 ../txt/
copy "..\txt\hex\%FILE_NAME%.hex" "..\txt\%FILE_NAME%.txt" > nul

REM ==========================================
REM 5. 清理阶段：删除中间生成的 elf 文件
REM ==========================================
del %FILE_NAME%.elf
echo [+] 已清理临时文件 %FILE_NAME%.elf

echo.
echo === 全部完成！===
echo Hex 文件已保存至: ..\txt\hex\%FILE_NAME%.hex
echo Txt 文件已保存至: ..\txt\%FILE_NAME%.txt
echo.
pause