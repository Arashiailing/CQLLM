import json
import random

# 输入和输出文件路径
input_file = r"C:\code\CQLLM\v2.0\训练数据集\ql_dataset.json"
train_file = r"C:\code\CQLLM\v2.0\训练数据集\ql_dataset_train.json"
val_file = r"C:\code\CQLLM\v2.0\训练数据集\ql_dataset_val.json"

# 读取数据（整个是一个 list）
with open(input_file, "r", encoding="utf-8") as f:
    data = json.load(f)

print(f"原始数据集大小: {len(data)}")

# 打乱
random.shuffle(data)

# 按比例切分（90% 训练，10% 验证）
split = int(0.9 * len(data))
train_data = data[:split]
val_data = data[split:]

# 保存为 json（list 格式）
with open(train_file, "w", encoding="utf-8") as f:
    json.dump(train_data, f, ensure_ascii=False, indent=2)

with open(val_file, "w", encoding="utf-8") as f:
    json.dump(val_data, f, ensure_ascii=False, indent=2)

print(f"✅ 数据划分完成: train={len(train_data)}, val={len(val_data)}")
