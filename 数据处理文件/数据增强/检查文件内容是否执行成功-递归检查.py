import os
import subprocess
from tqdm import tqdm

# -------------------- 配置 --------------------
database_path = r"C:\code\CQLLM\CodeQL_for_db\db"
ql_root_folder = r"C:\code\ql\python\ql\src\Security\QL_for_Python\QL_for_Python\Classes"

def execute_ql(query_path: str) -> (str, bool, str):
    """
    执行 QL 查询
    :return: (文件路径, 是否成功, 错误信息)
    """
    try:
        result = subprocess.run(
            ["codeql", "query", "run", query_path, "--database", database_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            cwd=os.path.dirname(query_path)  # 使用 QL 文件所在目录
        )
        if result.returncode == 0:
            return query_path, True, ""
        else:
            return query_path, False, result.stderr
    except Exception as e:
        return query_path, False, str(e)

def get_all_ql_files(folder: str):
    """
    递归获取文件夹下所有 .ql 文件
    """
    ql_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".ql"):
                ql_files.append(os.path.join(root, file))
    return ql_files

if __name__ == "__main__":
    all_ql_files = get_all_ql_files(ql_root_folder)
    print(f"共找到 {len(all_ql_files)} 个 QL 文件，开始检查...")

    failed_queries = []

    # 单线程逐个执行，避免数据库锁冲突
    for ql_file in tqdm(all_ql_files, desc="Checking QL files"):
        ql_file_path, success, error = execute_ql(ql_file)
        if success:
            print(f"[成功] {ql_file_path}")
        else:
            print(f"[失败] {ql_file_path}\n错误信息:\n{error}\n")
            failed_queries.append((ql_file_path, error))

    print("\n检查完成！")
    if failed_queries:
        print(f"共有 {len(failed_queries)} 个 QL 文件执行失败。")
    else:
        print("所有 QL 文件执行成功！")
