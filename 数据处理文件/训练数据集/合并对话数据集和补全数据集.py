import json

# ---------------- 配置 ----------------
dialogue_file = r"C:\code\CQLLM\v2.0\训练数据集\alpaca_dataset.jsonl"      # 对话数据集
completion_file = r"C:\code\CQLLM\v2.0\训练数据集\completion_dataset.jsonl" # 补全数据集
output_file = r"C:\code\CQLLM\v2.0\训练数据集\dataset.jsonl"         # 合并后的文件

# ---------------- 工具函数 ----------------
def load_jsonl(path):
    data = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            if line.strip():
                try:
                    data.append(json.loads(line))
                except json.JSONDecodeError as e:
                    print(f"❌ JSON 解析错误: {e} @ {path}")
    return data

# ---------------- 主逻辑 ----------------
dialogue_data = load_jsonl(dialogue_file)
completion_data = load_jsonl(completion_file)

merged_data = dialogue_data + completion_data

# 打乱数据顺序（可选）
import random
random.shuffle(merged_data)

# ---------------- 输出 ----------------
with open(output_file, "w", encoding="utf-8") as f:
    for entry in merged_data:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

print(f"✅ 合并完成: {len(dialogue_data)} 条对话 + {len(completion_data)} 条补全 = {len(merged_data)} 条")
print(f"👉 输出文件: {output_file}")
