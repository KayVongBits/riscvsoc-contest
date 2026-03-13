import re

# 输入和输出文件名
input_file = "./tb/rv32ui-p-addi.dump"
output_file = "./tb/rv32ui-p-addi.txt"

with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
    for line in f_in:
        # 使用正则表达式匹配：冒号后面跟着制表符/空格，然后是连续的 8 个 16 进制字符
        match = re.search(r':\s+([0-9a-fA-F]{8})', line)
        if match:
            # 提取出来的就是我们要的机器码，写入 txt，一行一个
            machine_code = match.group(1)
            f_out.write(machine_code + "\n")

print(f"转换成功！文件已保存为 {output_file}")