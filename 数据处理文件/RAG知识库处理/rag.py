import pandas as pd
import json

# 输入 XLSX 文件路径
input_xlsx = r"C:\研究生\乱七八糟的东西\AWD\codeql_python_all.xlsx"
# 输出 JSONL 文件路径
output_jsonl = r"C:\研究生\乱七八糟的东西\AWD\modules_rag.jsonl"

# 读取第一个 sheet
df = pd.read_excel(input_xlsx, sheet_name=0)  # 如果想遍历所有 sheet，可以用 sheet_name=None

# 打开 JSONL 文件写入
with open(output_jsonl, 'w', encoding='utf-8') as jsonlfile:
    for _, row in df.iterrows():
        fragment = {
            "import_path": str(row['import_path']).strip(),
            "section_type": str(row['section_type']).strip(),
            "entity": str(row.get('entity_name', '')).strip()
        }
        jsonlfile.write(json.dumps(fragment, ensure_ascii=False) + "\n")

print(f"完成拆分，生成 {output_jsonl}")
