import os

ql_folder = r"C:\code\ql\python\ql\src\Security\QL_for_Python\Security"
for filename in os.listdir(ql_folder):
    if not filename.endswith(".ql"):
        continue

    ql_path = os.path.join(ql_folder, filename)
    print(ql_path)