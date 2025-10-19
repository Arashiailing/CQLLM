import json
import os

# ---------------- 配置 ----------------
file_path = r"C:\code\CQLLM\v2.0\训练数据集\ql_dataset_val.json"

def check_json_file(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            if file_path.endswith(".jsonl"):
                # 校验每一行
                for i, line in enumerate(f, 1):
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        json.loads(line)
                    except json.JSONDecodeError as e:
                        print(f"[ERROR] {file_path} 行 {i}: {e}")
                        return False
            else:
                # 普通 JSON 文件
                json.load(f)
        print(f"[OK] {file_path} 格式正确")
        return True
    except json.JSONDecodeError as e:
        print(f"[ERROR] {file_path}: {e}")
        return False
    except Exception as e:
        print(f"[ERROR] {file_path}: {e}")
        return False

if __name__ == "__main__":
    if os.path.exists(file_path):
        check_json_file(file_path)
    else:
        print(f"[ERROR] 文件不存在: {file_path}")
