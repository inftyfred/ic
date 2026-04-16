import re
import sys
from pathlib import Path


def extract_machine_code(asm_text):
    """从反汇编文本中提取机器码，一行一个32位十六进制数"""
    codes = []
    # 匹配格式：地址:  8位十六进制机器码
    pattern = re.compile(r'^\s*[0-9a-fA-F]+:\s+([0-9a-fA-F]{8})\b', re.MULTILINE)

    for match in pattern.finditer(asm_text):
        codes.append(match.group(1))

    return codes


def main():
    # 检查命令行参数数量
    if len(sys.argv) != 2:
        print("用法: python extract_machine_code.py <dump文件路径>")
        sys.exit(1)

    input_path = Path(sys.argv[1])

    # 检查输入文件是否存在
    if not input_path.exists():
        print(f"错误: 文件 '{input_path}' 不存在")
        sys.exit(1)

    # 生成输出文件路径：替换扩展名为 .txt，如果没有扩展名则直接加 .txt
    output_path = input_path.with_suffix('.txt')

    # 读取输入文件内容
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"读取文件失败: {e}")
        sys.exit(1)

    # 提取机器码
    machine_codes = extract_machine_code(content)

    # 写入输出文件，每行一个机器码
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(machine_codes))
    except Exception as e:
        print(f"写入文件失败: {e}")
        sys.exit(1)

    print(f"成功提取 {len(machine_codes)} 条机器码，已保存到: {output_path}")


if __name__ == '__main__':
    main()

