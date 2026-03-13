import re
import os

# 配置文件名，请确保这两个文件和脚本在同一个目录下
DUMP_FILE = "./tb/rv32ui-p-addi.dump"
TXT_FILE = "./tb/rv32ui-p-addi.txt"

def verify_conversion():
    print("=============================================")
    print("🔍 开始交叉验证机器码转换结果...")
    print("=============================================\n")

    # 1. 检查文件是否存在
    if not os.path.exists(DUMP_FILE):
        print(f"❌ 找不到原始文件: {DUMP_FILE}")
        return
    if not os.path.exists(TXT_FILE):
        print(f"❌ 找不到转换文件: {TXT_FILE}")
        return

    # 2. 从 .dump 文件中提取基准答案 (Expected)
    expected_codes = []
    with open(DUMP_FILE, "r") as f_dump:
        for line_num, line in enumerate(f_dump, 1):
            # 匹配 8 位 16 进制机器码
            match = re.search(r':\s+([0-9a-fA-F]{8})', line)
            if match:
                # 统一转成小写，避免大小写差异导致误报
                expected_codes.append({
                    "line": line_num,
                    "code": match.group(1).lower()
                })

    # 3. 读取 .txt 文件中的实际转换结果 (Actual)
    actual_codes = []
    with open(TXT_FILE, "r") as f_txt:
        for line_num, line in enumerate(f_txt, 1):
            code = line.strip().lower()
            if code:  # 忽略空行
                actual_codes.append({
                    "line": line_num,
                    "code": code
                })

    # 4. 开始比对
    print(f"📊 统计信息: Dump文件包含 {len(expected_codes)} 条指令, TXT文件包含 {len(actual_codes)} 条指令。\n")
    
    # 检查数量是否一致
    if len(expected_codes) != len(actual_codes):
        print(f"❌ [严重错误] 指令数量不匹配！存在漏提或多提的情况。")
        return

    # 逐条检查内容
    error_count = 0
    for i in range(len(expected_codes)):
        expected = expected_codes[i]
        actual = actual_codes[i]
        
        if expected["code"] != actual["code"]:
            print(f"❌ [不匹配] TXT文件第 {actual['line']} 行: ")
            print(f"   ├─ 期望值 (Dump第{expected['line']}行): {expected['code']}")
            print(f"   └─ 实际值: {actual['code']}")
            error_count += 1

    # 5. 输出最终结论
    print("-" * 45)
    if error_count == 0:
        print(f"✅ 验证完美通过！所有 {len(expected_codes)} 条机器码100%一致！")
        print("🚀 放心丢进 ModelSim 里跑仿真吧！")
    else:
        print(f"⚠️ 验证失败！共发现 {error_count} 处不一致，请检查转换脚本或文件。")
    print("=============================================")

if __name__ == "__main__":
    verify_conversion()