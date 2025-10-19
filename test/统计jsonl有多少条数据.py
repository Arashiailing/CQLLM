import json

def count_json(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return len(data)


if __name__ == "__main__":
    file_path = r"C:\code\CQLLM\v2.0\训练数据集\ql_dataset_train.json"

    total = count_json(file_path)
    print(f"文件 {file_path} 中共有 {total} 条数据")

