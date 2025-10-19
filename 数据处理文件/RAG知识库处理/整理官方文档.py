import pandas as pd
import json

# 假设表格是 CSV 格式
# df = pd.read_csv("module_table.csv")  # 或
df = pd.read_excel("C:\研究生\乱七八糟的东西\AWD\codeql_python_all.xlsx")

result = {}

for _, row in df.iterrows():
    import_path = row['import_path']
    section_type = row['section_type']
    entity_name = row['entity_name']

    if pd.isna(import_path) or pd.isna(section_type) or pd.isna(entity_name):
        continue

    if import_path not in result:
        result[import_path] = {}
    if section_type not in result[import_path]:
        result[import_path][section_type] = []

    # 避免重复
    if entity_name not in result[import_path][section_type]:
        result[import_path][section_type].append(entity_name)

# 输出 JSON
with open("使用方法.json", "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

print("Done! JSON saved to 使用方法.json")
