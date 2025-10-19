import os
import time
import subprocess
import pandas as pd
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
from zai import ZhipuAiClient

# -------------------- 配置 --------------------
client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

excel_path = r"C:\code\CQLLM\v2.0\数据增强\32M文件aug\CodeQL_All-test.xlsx"
save_root = r"C:\code\ql\aug"  # 增强后QL文件保存的根目录
database_path = r"C:\code\CQLLM\CodeQL_for_db\db"
MAX_RETRIES = 1
MAX_WORKERS = 5

# -------------------- Prompt 模板 --------------------
BASE_PROMPT_TEMPLATE = """
你是一名资深 CodeQL 安全分析专家。
请对下面的 CodeQL 查询进行增强：

增强方式：
1. 代码注释改写（保留逻辑）
2. 变量名替换（保持语义一致）
3. 代码片段重组（拆分/合并查询逻辑）

约束：
- 保留原有 import，不新增模块
- 不新增谓词或类
- select 子句保持输出格式
- 保证语法正确，可执行

原始 QL 代码：
{ql_code}
"""

FEEDBACK_PROMPT_TEMPLATE = """
这是数据增强后的代码：
{ql_code}
增强的 CodeQL 查询执行失败，错误信息如下：
{error_msg}

请保持原有增强逻辑（注释改写、变量名替换、代码片段重组）。
输出完整 QL 代码，不要解释。
"""

# -------------------- 工具函数 --------------------
def clean_result(text: str) -> str:
    """清理 LLM 输出的 ```ql 包裹"""
    if "```ql" in text:
        text = text.split("```ql", 1)[1]
    if "```" in text:
        text = text.split("```", 1)[0]
    return text.strip()

def execute_ql(query_path: str) -> (bool, str):
    """执行 QL 查询"""
    try:
        result = subprocess.run(
            ["codeql", "query", "run", query_path, "--database", database_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8"
        )
        if result.returncode == 0:
            return True, ""
        else:
            return False, result.stderr
    except Exception as e:
        return False, str(e)

def call_llm(prompt: str) -> str:
    """调用 LLM 生成增强或修复结果"""
    response = client.chat.completions.create(
        model="glm-4.5",
        messages=[{"role": "user", "content": prompt}]
    )
    return clean_result(response.choices[0].message.content)

# -------------------- 读取 Excel --------------------
df = pd.read_excel(excel_path)
print(f"📖 从 Excel 读取 {len(df)} 条 QL 记录")

# 检查必要字段
required_cols = {"QL_content", "Explore", "Query_id"}
if not required_cols.issubset(df.columns):
    raise ValueError(f"Excel 文件缺少必要字段：{required_cols - set(df.columns)}")

# -------------------- 单条处理逻辑 --------------------
def process_row(row):
    ql_code = str(row["QL_content"])
    explore_path = str(row["Explore"]).strip().replace("\\", "/").replace(" ", "_")  # 替换空格为下划线
    query_id = str(row["Query_id"]).strip()

    # 构建保存路径
    save_dir = os.path.normpath(os.path.join(save_root, *explore_path.split("/")))
    os.makedirs(save_dir, exist_ok=True)
    temp_path = os.path.join(save_dir, f"temp_aug_{query_id}.ql")
    final_path = os.path.join(save_dir, f"aug_{query_id}.ql")

    retries, success = 0, False
    current_code, feedback_msg = "", ""

    while retries < MAX_RETRIES and not success:
        try:
            if retries == 0:
                prompt = BASE_PROMPT_TEMPLATE.format(ql_code=ql_code)
            else:
                prompt = FEEDBACK_PROMPT_TEMPLATE.format(
                    ql_code=current_code, error_msg=feedback_msg
                )

            current_code = call_llm(prompt)
            print(current_code)
            with open(temp_path, "w", encoding="utf-8") as f:
                f.write(current_code)

            ok, error_msg = execute_ql(temp_path)
            if ok:
                os.replace(temp_path, final_path)
                return query_id, True, f"✅ 成功增强并验证 -> {final_path}"
            else:
                feedback_msg = error_msg
                retries += 1
                time.sleep(2 ** retries)

        except Exception as e:
            feedback_msg = str(e)
            retries += 1
            time.sleep(2 ** retries)

    if os.path.exists(temp_path):
        os.remove(temp_path)
    return query_id, False, f"❌ 增强失败，已重试 {MAX_RETRIES} 次"

# -------------------- 并行执行 --------------------
success_count, fail_count = 0, 0
with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    futures = {executor.submit(process_row, row): row for _, row in df.iterrows()}
    for future in tqdm(as_completed(futures), total=len(futures), desc="处理 QL 数据", unit="条"):
        query_id, success, msg = future.result()
        print(f"\n{msg}")
        if success:
            success_count += 1
        else:
            fail_count += 1

print(f"\n🎯 处理完成：成功 {success_count} 条，失败 {fail_count} 条，总数 {len(df)}")
