import os


def count_qll_files(root_dir):
    qll_count = 0
    qll_files = []

    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.lower().endswith(".qll"):
                qll_count += 1
                qll_files.append(os.path.join(dirpath, filename))

    return qll_count, qll_files


if __name__ == "__main__":
    # 修改为你要检查的目录路径
    target_dir = "C:\code\ql\python\ql\src\Security"

    count, files = count_qll_files(target_dir)
    print(f"在目录 {os.path.abspath(target_dir)} 下，共找到 {count} 个 .qll 文件")
    for f in files:
        print(f)
