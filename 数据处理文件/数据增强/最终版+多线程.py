import os
import time
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
from zai import ZhipuAiClient

# -------------------- 配置 --------------------
client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

ql_root = r"C:\code\ql\python\ql\src\Security\QL_for_Python"  # 根目录，递归搜索
database_path = r"C:\code\CQLLM\CodeQL_for_db\db"
MAX_RETRIES = 1  # 最多修复次数
MAX_WORKERS = 5  # 最大线程数，可根据 CPU/IO 调整

# -------------------- Prompt 模板 --------------------
BASE_PROMPT_TEMPLATE = """
你是一名资深 CodeQL 安全分析专家。
请对下面的 CodeQL 查询进行增强：

增强方式：
1. 代码注释改写（保留逻辑）
没有RAG. 变量名替换（保持语义一致）
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
这是数据增强后的代码
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
    """执行 QL 查询，返回是否成功和错误信息"""
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

# -------------------- 收集所有 QL 文件 --------------------
ql_files = []
for root, _, files in os.walk(ql_root):
    for filename in files:
        if filename.endswith(".ql"):
            ql_files.append((root, filename))

print(f"📂 共找到 {len(ql_files)} 个 QL 文件")

# -------------------- 处理单个 QL 文件函数 --------------------
def process_file(root_filename):
    root, filename = root_filename
    ql_path = os.path.join(root, filename)
    with open(ql_path, "r", encoding="utf-8") as f:
        ql_code = f.read()

    retries, success = 0, False
    current_code, feedback_msg = "", ""
    temp_path = os.path.join(root, f"temp_aug_{filename}")

    while retries < MAX_RETRIES and not success:
        try:
            if retries == 0:
                prompt = BASE_PROMPT_TEMPLATE.format(ql_code=ql_code)
            else:
                prompt = FEEDBACK_PROMPT_TEMPLATE.format(
                    ql_code=current_code,
                    error_msg=feedback_msg
                )

            current_code = call_llm(prompt)

            with open(temp_path, "w", encoding="utf-8") as f:
                f.write(current_code)

            ok, error_msg = execute_ql(temp_path)
            if ok:
                final_path = os.path.join(root, f"augl_{filename}")
                os.replace(temp_path, final_path)
                return filename, True, f"✅ 已增强并执行成功 -> {final_path}"
            else:
                feedback_msg = error_msg
                retries += 1
                time.sleep(2 ** retries)
        except Exception as e:
            feedback_msg = str(e)
            retries += 1
            time.sleep(2 ** retries)

    # 如果失败
    if os.path.exists(temp_path):
        os.remove(temp_path)
    return filename, False, f"❌ 连续 {MAX_RETRIES} 次失败，已放弃"

# -------------------- 多线程处理 --------------------
success_count, fail_count = 0, 0
with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    futures = {executor.submit(process_file, f): f for f in ql_files}
    for future in tqdm(as_completed(futures), total=len(futures), desc="处理 QL 文件", unit="file"):
        filename, success, msg = future.result()
        print(f"\n{msg}")
        if success:
            success_count += 1
        else:
            fail_count += 1

# -------------------- 总结 --------------------
print(f"\n🎯 处理完成：成功 {success_count} 个，失败 {fail_count} 个，总数 {len(ql_files)}")
