import re
import argparse


def extract_machine_code(asm_text):
    """从反汇编文本中提取机器码，一行一个32位十六进制数"""
    codes = []
    # 匹配格式：地址:  8位十六进制机器码
    pattern = re.compile(r'^\s*[0-9a-fA-F]+:\s+([0-9a-fA-F]{8})\b', re.MULTILINE)

    for match in pattern.finditer(asm_text):
        codes.append(match.group(1))

    return codes


def main():
    parser = argparse.ArgumentParser(description='从RISC-V反汇编文件中提取机器码')
    parser.add_argument('-i', '--input', required=True, help='输入的反汇编文件路径')
    parser.add_argument('-o', '--output', default='machine_code.txt', help='输出文件路径（默认 machine_code.txt）')
    args = parser.parse_args()

    with open(args.input, 'r') as f:
        asm_text = f.read()

    codes = extract_machine_code(asm_text)

    with open(args.output, 'w') as f:
        for code in codes:
            f.write(code + '\n')

    print(f'提取完成，共 {len(codes)} 条指令，已写入 {args.output}')


if __name__ == '__main__':
    main()














































