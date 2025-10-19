import os

root_dir = r"C:\code\ql\python\ql\src\Security"

ql_count = 0
qll_count = 0

for dirpath, dirnames, filenames in os.walk(root_dir):
    for filename in filenames:
        if filename.lower().endswith(".ql"):
            ql_count += 1
        elif filename.lower().endswith(".qll"):
            qll_count += 1

print(f".ql 文件数量: {ql_count}")
print(f".qll 文件数量: {qll_count}")
print(f"总文件数量: {ql_count + qll_count}")
