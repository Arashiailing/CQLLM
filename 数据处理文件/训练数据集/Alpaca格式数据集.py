import os
import json
import random
import re

# ---------------- 配置 ----------------
ql_root = r"C:\code\CQLLM\v2.0\数据增强\QL_for_Python"  # QL文件目录
output_alpaca = r"C:\code\CQLLM\v2.0\训练数据集\alpaca_dataset.jsonl"
output_completion = r"C:\code\CQLLM\v2.0\训练数据集\completion_dataset.jsonl"

# ---------------- 工具函数 ----------------
def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def extract_meta(ql_code):
    """从注释头里提取 name/description/id"""
    match = re.search(r"/\*\*(.*?)\*/", ql_code, re.S)
    if not match:
        return {}
    block = match.group(1)
    name = re.search(r"@name\s+(.*)", block)
    desc = re.search(r"@description\s+(.*)", block)
    cwe_id = re.search(r"@id\s+(.*)", block)
    return {
        "name": name.group(1).strip() if name else "",
        "desc": desc.group(1).strip() if desc else "",
        "id": cwe_id.group(1).strip() if cwe_id else "UNKNOWN"
    }

def make_alpaca_entry(meta, ql_code, lang="python"):
    """构造 Alpaca 数据条目"""
    cwe = meta.get("id") or "UNKNOWN"
    desc = meta.get("desc") or meta.get("name") or "未知任务"
    return {
        "instruction": f"[[TASK=GENERATE]] [[MODE=QL_ONLY]] [[LANG={lang}]] [[CWE={cwe}]] "
                       f"你是一名资深 CodeQL 安全分析专家。目标：根据用户需求生成【可执行】的 CodeQL 查询。"
                       f"硬性规则：1) 仅输出 QL 代码，不要任何解释或注释；2) 代码需符合官方语义模型与模块导入；3) 语法正确、可直接执行。"
                       f"编写一个CodeQL查询：{desc}",
        "input": "基于 CWE 的漏洞检测任务，请输出完整QL代码。",
        "output": ql_code.strip()
    }

def make_completion_entry(ql_code):
    """构造补全任务数据：随机挖掉一行"""
    lines = ql_code.strip().split("\n")
    if len(lines) < 5:
        return None

    # 候选行（避免 import / select）
    candidates = [i for i, l in enumerate(lines) if "import" not in l and "select" not in l]
    if not candidates:
        return None

    idx = random.choice(candidates)
    removed = lines[idx].strip()
    lines[idx] = "_______________ // 补全条件"

    return {
        "instruction": "补全以下CodeQL查询。",
        "input": "\n".join(lines),
        "output": removed
    }

# ---------------- 主逻辑 ----------------
alpaca_data = []
completion_data = []

for root, _, files in os.walk(ql_root):
    for file in files:
        if not file.endswith(".ql"):
            continue
        path = os.path.join(root, file)
        try:
            ql_code = read_file(path)
            meta = extract_meta(ql_code)

            # 确定语言（根据路径或扩展）
            lang = "python" if "python" in path.lower() else "cpp" if "cpp" in path.lower() else "java"

            # 生成 alpaca 数据
            if meta:
                alpaca_data.append(make_alpaca_entry(meta, ql_code, lang=lang))

            # 生成补全数据
            comp = make_completion_entry(ql_code)
            if comp:
                completion_data.append(comp)

        except Exception as e:
            print(f"❌ 处理失败: {path}, 错误: {e}")

# ---------------- 输出 ----------------
os.makedirs(os.path.dirname(output_alpaca), exist_ok=True)

with open(output_alpaca, "w", encoding="utf-8") as f:
    for entry in alpaca_data:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

with open(output_completion, "w", encoding="utf-8") as f:
    for entry in completion_data:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

print(f"✅ Alpaca 数据集: {len(alpaca_data)} 条 → {output_alpaca}")
print(f"✅ 补全 数据集: {len(completion_data)} 条 → {output_completion}")
