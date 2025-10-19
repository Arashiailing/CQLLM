import csv
import os
import subprocess
from tqdm import tqdm

ql_root = r"C:\code\ql\python\ql\src\Security\qwen2.5-7B-noft-RAG\ql_outputs"  # 根目录，递归搜索
database_path = r"C:\code\CQLLM\experience\Python_CWE_Bench\python_cwe_bench_codeql_database"
CSV_FILE = r"C:\code\CQLLM-Python10\CQLLM-Python10\给老师看过后\消融实验\qwen2.5-7B-noft-RAG\qwen2.5-7B-noft-RAG.csv"  # CSV 输出路径
# 查询结果输出目录;bqrs格式的
output_dir = r"C:\code\CQLLM-Python10\CQLLM-Python10\给老师看过后\消融实验\qwen2.5-7B-noft-RAG\bqrs"
os.makedirs(output_dir, exist_ok=True)

def write_result_to_csv(ql_path: str, vuln_count: int, csv_file: str = CSV_FILE):
    """
    将单条结果追加写入 csv（如果文件不存在则先写入表头）。
    字段：ql_path, vuln_count
    """
    write_header = not os.path.exists(csv_file)
    # newline='' 防止 windows 下写入空行
    with open(csv_file, mode='a', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["ql_path", "vuln_count"])
        if write_header:
            writer.writeheader()
        writer.writerow({"ql_path": ql_path, "vuln_count": vuln_count})



def execute_ql(query_path: str, output_path: str) -> (bool, str):
    """执行 QL 查询，返回是否成功和错误信息"""
    try:
        result = subprocess.run(
            ["codeql", "query", "run", query_path, "--database", database_path, "--output", output_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8"
        )
        if result.returncode == 0:
            return True, ""
        else:
            return False, result.stderr
    except Exception as e:
        return False, str(e)

# 递归获取所有 QL 文件
ql_files = []
for root, dirs, files in os.walk(ql_root):
    for file in files:
        if file.endswith(".ql"):
            ql_files.append(os.path.join(root, file))

# 遍历执行 QL 查询，显示进度条
total_vulns = 0
for ql_path in tqdm(ql_files, desc="Executing QL files"):
    filename = os.path.splitext(os.path.basename(ql_path))[0]
    output_path = os.path.join(output_dir, f"{filename}.bqrs")

    success, err = execute_ql(ql_path, output_path)
    if success:
        # 使用 codeql bqrs decode 获取结果行数（漏洞数量）
        decode_result = subprocess.run(
            ["codeql", "bqrs", "decode", output_path, "--format=csv"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8"
        )
        if decode_result.returncode == 0:
            lines = decode_result.stdout.strip().split("\n")
            vuln_count = max(len(lines) - 1, 0)  # 减去表头
            total_vulns += vuln_count
            tqdm.write(f"{ql_path} -> {vuln_count} 漏洞")
            write_result_to_csv(ql_path, vuln_count)
        else:
            tqdm.write(f"{ql_path} -> decode 失败: {decode_result.stderr}")
    else:
        tqdm.write(f"{ql_path} -> 执行失败: {err}")

print(f"\n所有 QL 查询完成，总共发现漏洞: {total_vulns}")

# 结果，共49条ql，其中找到漏洞的CWE有15个，占比30%,感觉不合格呢
# 无漏洞的 CWE（漏洞数 = 0）：CWE-074, CWE-089, CWE-090, CWE-094, CWE-116, CWE-117, CWE-215, CWE-285, CWE-295, CWE-326, CWE-352, CWE-502, CWE-611, CWE-643, CWE-776, CWE-943
# CWE	Total Vulnerabilities
# CWE-020	702
# CWE-022	108
# CWE-078	24
# CWE-079	35
# CWE-113	2
# CWE-209	6
# CWE-312	11
# CWE-327	34
# CWE-377	20
# CWE-601	3
# CWE-614	10
# CWE-730	4
# CWE-732	5
# CWE-798	14
# CWE-918	1