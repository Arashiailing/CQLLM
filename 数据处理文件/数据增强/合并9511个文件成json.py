import os
import json
from tqdm import tqdm   # pip install tqdm

# 配置
root_dir = r"C:\code\ql\python\ql\src\Security\QL_for_Python\QL_for_Python"   # 递归搜索的根目录
output_dir = r"C:\code\CQLLM\v2.0\数据增强"           # 合并后的json输出目录
max_size_bytes = 900 * 1024 * 1024       # 单个JSON文件最大限制（900MB，留点余量）

os.makedirs(output_dir, exist_ok=True)

def collect_ql_files(root_dir):
    ql_files = []
    for dirpath, _, filenames in os.walk(root_dir):
        for f in filenames:
            if f.endswith(".ql"):
                ql_files.append(os.path.join(dirpath, f))
    return ql_files

def merge_files_to_json(ql_files):
    batch = []
    batch_size = 0
    file_index = 1

    for ql_file in tqdm(ql_files, desc="合并进度", unit="file"):
        try:
            with open(ql_file, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except Exception as e:
            tqdm.write(f"[跳过错误文件] {ql_file}: {e}")
            continue

        # 使用相对路径作为文件名（避免绝对路径）
        rel_path = os.path.relpath(ql_file, root_dir)

        item = {"filename": rel_path, "content": content}
        item_str = json.dumps(item, ensure_ascii=False)

        # 判断是否超过单文件限制
        if batch_size + len(item_str.encode("utf-8")) > max_size_bytes and batch:
            output_path = os.path.join(output_dir, f"merged_{file_index}.json")
            with open(output_path, "w", encoding="utf-8") as out:
                json.dump(batch, out, ensure_ascii=False, indent=2)
            tqdm.write(f"[保存] {output_path}, 大小 {batch_size/1024/1024:.2f} MB, 含 {len(batch)} 个QL文件")

            # 新建批次
            file_index += 1
            batch = []
            batch_size = 0

        batch.append(item)
        batch_size += len(item_str.encode("utf-8"))

    # 保存最后一批
    if batch:
        output_path = os.path.join(output_dir, f"merged_{file_index}.json")
        with open(output_path, "w", encoding="utf-8") as out:
            json.dump(batch, out, ensure_ascii=False, indent=2)
        tqdm.write(f"[保存] {output_path}, 大小 {batch_size/1024/1024:.2f} MB, 含 {len(batch)} 个QL文件")


if __name__ == "__main__":
    ql_files = collect_ql_files(root_dir)
    print(f"总共找到 {len(ql_files)} 个 QL 文件")
    merge_files_to_json(ql_files)
    print("✅ 合并完成！")
