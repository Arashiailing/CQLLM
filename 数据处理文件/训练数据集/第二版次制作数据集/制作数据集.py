import os
import json
import re
import random

# ---------------- 配置 ----------------
ql_root = r"C:\code\ql\python\ql\src"
output_json = r"C:\code\CQLLM\v2.0\训练数据集\第二版次制作数据集\dataset.json"
completion_versions = 2  # 每个QL文件生成的补全版本数

# ---------------- 工具函数 ----------------
def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def extract_comment_meta(ql_code, file_path):
    """
    提取注释元信息，如果缺字段或不是完整格式，生成占位。
    只判断是否存在 @name 注释
    """
    match = re.search(r"/\*\*(.*?)\*/", ql_code, re.S)
    base_name = os.path.splitext(os.path.basename(file_path))[0]
    meta = {"name": "", "desc": "", "id": ""}

    if match:
        block = match.group(1)
        name = re.search(r"@name\s+(.*)", block)
        desc = re.search(r"@description\s+(.*)", block)
        cwe_id = re.search(r"@id\s+(.*)", block)

        if name:
            # 注释存在 @name → 按原注释处理，缺字段自动补齐
            meta["name"] = name.group(1).strip()
            meta["desc"] = desc.group(1).strip() if desc else meta["name"]
            meta["id"] = cwe_id.group(1).strip() if cwe_id else f"py/{base_name.lower()}"
        else:
            # 注释存在但没有 @name → 占位 name/id，整段注释作为 description
            meta["name"] = f"检测 {base_name} 的规则"
            meta["desc"] = re.sub(r"\s*\*\s?", " ", block).strip()  # 去掉 * 号前缀
            meta["id"] = f"py/{base_name.lower()}"
    else:
        # 无注释 → 生成占位
        meta["name"] = f"检测 {base_name} 的规则"
        meta["desc"] = f"这是一个检测 {base_name} 的 CodeQL 查询，占位描述。"
        meta["id"] = f"py/{base_name.lower()}"

    return meta

def make_alpaca_entry(meta, ql_code):
    """构造对话任务（Alpaca 风格）"""
    cwe = meta.get("id")
    desc = meta.get("desc")
    return {
        "instruction": (
            f"你是一个优秀的CodeQL代码助手，能够很好的理解并解释CodeQL。请编写一个检测{cwe}漏洞的CodeQL查询代码："
            f"@name {meta.get('name')} "
            f"@description {desc} "
            f"@id {cwe} "
            f"请编写相应的CodeQL查询代码，只需要给出ql代码，不需要给出描述信息。"
        ),
        "input": "基于 CWE 的漏洞检测任务，请输出完整QL代码。",
        "output": ql_code.strip()
    }

def make_completion_entries(ql_code, versions=2):
    """
    构造补全任务数据：随机遮蔽非 import/select/注释行，生成多版本
    """
    lines = ql_code.strip().split("\n")
    if len(lines) < 5:
        return []

    # 候选行（避免 import / select / 注释行）
    candidates = [i for i, l in enumerate(lines)
                  if "import" not in l and "select" not in l and not re.match(r"^\s*/\*", l)]
    if not candidates:
        return []

    entries = []
    for _ in range(versions):
        idx = random.choice(candidates)
        removed = lines[idx].strip()
        temp_lines = lines.copy()
        temp_lines[idx] = "/* MISSING */"
        entries.append({
            "instruction": "补全以下CodeQL查询。",
            "input": "\n".join(temp_lines),
            "output": removed
        })
    return entries

# ---------------- 主逻辑 ----------------
dataset = []

for root, _, files in os.walk(ql_root):
    for file in files:
        if not file.endswith(".ql"):
            continue
        path = os.path.join(root, file)
        try:
            ql_code = read_file(path)
            meta = extract_comment_meta(ql_code, path)

            # 对话任务
            dataset.append(make_alpaca_entry(meta, ql_code))

            # 补全任务，多版本
            completion_entries = make_completion_entries(ql_code, versions=completion_versions)
            dataset.extend(completion_entries)

        except Exception as e:
            print(f"❌ 处理失败: {path}, 错误: {e}")

# ---------------- 输出 JSON ----------------
os.makedirs(os.path.dirname(output_json), exist_ok=True)
with open(output_json, "w", encoding="utf-8") as f:
    json.dump(dataset, f, ensure_ascii=False, indent=2)

print(f"✅ 总数据条目数: {len(dataset)}，已输出到 {output_json}")
