import re
import os

# ==========================================
# 📂 目录配置区 (可根据你的实际路径修改)
# ==========================================
DUMP_DIR = "./test_data/dump"
TXT_DIR  = "./test_data/txt"

def batch_convert_and_verify():
    print("=====================================================")
    print("      🚀 RISC-V 机器码批量提取与验证自动化工具")
    print("=====================================================\n")

    # 1. 检查输入目录是否存在
    if not os.path.exists(DUMP_DIR):
        print(f"❌ 找不到输入目录: {DUMP_DIR}")
        print("👉 请确保配置了正确的 DUMP_DIR 路径。")
        return

    # 安全机制：如果 txt 输出文件夹不存在，自动创建它
    os.makedirs(TXT_DIR, exist_ok=True)

    # 2. 扫描目录下所有文件，严格过滤出以 .dump 结尾的文件
    all_files = os.listdir(DUMP_DIR)
    dump_files = [f for f in all_files if f.endswith(".dump")]

    if not dump_files:
        print(f"⚠️ 在 {DUMP_DIR} 目录下没有找到任何 .dump 文件！")
        return

    print(f"📂 扫描完毕！共发现 {len(dump_files)} 个 .dump 测试文件。")
    print("⏳ 开始批量流水线作业...\n")
    print("-" * 53)

    # 统计数据
    success_count = 0
    fail_count = 0

    # 3. 遍历处理每一个 .dump 文件
    for filename in dump_files:
        test_name = filename.replace(".dump", "") # 去除后缀拿到纯文件名
        dump_path = os.path.join(DUMP_DIR, filename)
        txt_path = os.path.join(TXT_DIR, f"{test_name}.txt")

        print(f"▶️ 正在处理: [{test_name}]")
        
        # ---------------------------------------------------
        # 阶段一：提取机器码 (Dump -> TXT)
        # ---------------------------------------------------
        extract_success = True
        try:
            with open(dump_path, "r") as f_in, open(txt_path, "w") as f_out:
                for line in f_in:
                    match = re.search(r':\s+([0-9a-fA-F]{8})', line)
                    if match:
                        f_out.write(match.group(1) + "\n")
            print("   ├─ ⚙️ 提取: 成功")
        except Exception as e:
            print(f"   ├─ ❌ 提取: 失败 ({e})")
            extract_success = False

        if not extract_success:
            fail_count += 1
            print("-" * 53)
            continue # 如果提取失败，直接跳过当前文件，去处理下一个

        # ---------------------------------------------------
        # 阶段二：交叉验证
        # ---------------------------------------------------
        expected_codes = []
        with open(dump_path, "r") as f_dump:
            for line in f_dump:
                match = re.search(r':\s+([0-9a-fA-F]{8})', line)
                if match:
                    expected_codes.append(match.group(1).lower())

        actual_codes = []
        with open(txt_path, "r") as f_txt:
            for line in f_txt:
                code = line.strip().lower()
                if code:
                    actual_codes.append(code)
        
        # 开始核对
        if len(expected_codes) != len(actual_codes):
            print(f"   └─ ❌ 验证: 失败 (数量不匹配 Dump:{len(expected_codes)} TXT:{len(actual_codes)})")
            fail_count += 1
            print("-" * 53)
            continue

        error_count = 0
        for i in range(len(expected_codes)):
            if expected_codes[i] != actual_codes[i]:
                error_count += 1

        if error_count == 0:
            print(f"   └─ 🔍 验证: 通过完美匹配 ({len(expected_codes)} 条指令)")
            success_count += 1
        else:
            print(f"   └─ ❌ 验证: 失败 (发现 {error_count} 处机器码不一致)")
            fail_count += 1
            
        print("-" * 53)

    # 4. 输出最终汇总报告
    print("\n=====================================================")
    print("                 📊 批量处理最终报告")
    print("=====================================================")
    print(f"   总计文件 : {len(dump_files)} 个")
    print(f"   ✅ 成 功 : {success_count} 个")
    if fail_count > 0:
        print(f"   ❌ 失 败 : {fail_count} 个")
    print("=====================================================\n")

if __name__ == "__main__":
    batch_convert_and_verify()