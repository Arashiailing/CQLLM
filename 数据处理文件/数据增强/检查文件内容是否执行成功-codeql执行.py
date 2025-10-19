import subprocess
import os

# -------------------- 配置 --------------------
# 这里填写你的 CodeQL 数据库路径
database_path = r"C:\code\CQLLM\CodeQL_for_db\db"

def execute_ql(query_path: str) -> (bool, str):
    """
    执行 QL 查询，返回是否成功和错误信息
    :param query_path: QL 文件路径
    :return: (执行成功: bool, 错误信息: str)
    """
    if not os.path.isfile(query_path):
        return False, f"QL 文件不存在: {query_path}"

    try:
        result = subprocess.run(
            ["codeql", "query", "run", query_path, "--database", database_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8"
        )
        if result.returncode == 0:
            return True, result.stdout
        else:
            return False, result.stderr
    except Exception as e:
        return False, str(e)


if __name__ == "__main__":
    # 测试 QL 文件路径
    ql_file = r"C:\code\ql\python\ql\src\Security\QL_for_Python\QL_for_Python\aug1_AlertSuppression.ql"

    success, output = execute_ql(ql_file)
    if success:
        print(f"QL 文件执行成功:\n{output}")
    else:
        print(f"QL 文件执行失败:\n{output}")
