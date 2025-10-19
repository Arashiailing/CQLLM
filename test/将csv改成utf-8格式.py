#!/usr/bin/env python3
# convert_csv_to_utf8.py
import os
import chardet   # 用于自动检测编码
import codecs

# 输入文件夹路径（修改为你的目录）
FOLDER = r"C:\研究生\毕业论文\备份数据\实验整理\对比实验\analysis_root\csvs"

def convert_to_utf8(file_path):
    # 读取原始文件编码
    with open(file_path, 'rb') as f:
        raw_data = f.read()
        detect_result = chardet.detect(raw_data)
        encoding = detect_result["encoding"]

    if encoding is None:
        print(f"[SKIP] Cannot detect encoding: {file_path}")
        return

    if encoding.lower() == "utf-8":
        print(f"[SKIP] Already UTF-8: {file_path}")
        return

    # 重新以原始编码读取，再以 UTF-8 保存
    try:
        with codecs.open(file_path, 'r', encoding=encoding, errors='ignore') as f:
            content = f.read()
        with codecs.open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"[OK] Converted {file_path} from {encoding} to UTF-8")
    except Exception as e:
        print(f"[ERROR] Failed converting {file_path}: {e}")

def batch_convert(folder):
    for root, _, files in os.walk(folder):
        for name in files:
            if name.lower().endswith(".csv"):
                convert_to_utf8(os.path.join(root, name))

if __name__ == "__main__":
    batch_convert(FOLDER)
