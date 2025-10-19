import os
import hashlib
import shutil
from tqdm import tqdm   # pip install tqdm

def get_file_hash(file_path, chunk_size=8192):
    """计算文件的 SHA256 哈希"""
    sha = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(chunk_size):
            sha.update(chunk)
    return sha.hexdigest()

def count_files(folder):
    """统计目录下文件总数"""
    count = 0
    for _, _, files in os.walk(folder):
        count += len(files)
    return count

def merge_folders(folder1, folder2, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    seen_hashes = {}  # {hash: relative_path}

    # 先统计总文件数，便于 tqdm 显示进度
    total_files = sum(len(files) for f in [folder1, folder2] for _, _, files in os.walk(f))
    pbar = tqdm(total=total_files, desc="合并进度", unit="file")

    for folder in [folder1, folder2]:
        for root, _, files in os.walk(folder):
            for file in files:
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, folder)  # 相对路径
                file_hash = get_file_hash(file_path)

                if file_hash not in seen_hashes:
                    # 第一次遇到，保存副本
                    target_path = os.path.join(output_folder, rel_path)
                    os.makedirs(os.path.dirname(target_path), exist_ok=True)
                    shutil.copy2(file_path, target_path)
                    seen_hashes[file_hash] = rel_path
                else:
                    # 已经存在相同内容的文件，不再复制
                    print(f"跳过重复文件: {file_path} 与 {seen_hashes[file_hash]} 内容相同")

                pbar.update(1)

    pbar.close()

    # 统计合并后文件总数
    total = count_files(output_folder)
    print(f"合并完成！最终文件总数: {total}")

if __name__ == "__main__":
    folder1 = r"C:\code\CQLLM\v2.0\数据增强\QL_for_Python-win10"
    folder2 = r"C:\code\CQLLM\v2.0\数据增强\QL_for_Python-win11"
    output_folder = r"C:\code\CQLLM\v2.0\数据增强\QL_for_Python"

    merge_folders(folder1, folder2, output_folder)
