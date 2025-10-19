import os
import time
import subprocess
from zai import ZhipuAiClient
from tqdm import tqdm

# -------------------- 配置 --------------------
client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

ql_root = r"C:\code\ql\python\ql\src\Security\QL_for_Python\Security"
database_path = r"C:\code\CQLLM\CodeQL_for_db\db"

MAX_RETRIES = 5

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
这是上一次生成的增强代码：
{ql_code}

执行失败，错误信息如下：
{error_msg}

请在保持增强逻辑的前提下修复，使其可以在 CodeQL 中正常运行。
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

# -------------------- 主流程 --------------------
for root, _, files in os.walk(ql_root):
    for filename in files:
        if not filename.endswith(".ql"):
            continue

        ql_path = os.path.join(root, filename)
        with open(ql_path, "r", encoding="utf-8") as f:
            ql_code = f.read()

        retries, success = 0, False
        current_code = ""
        feedback_msg = ""
        temp_path = os.path.join(root, f"temp_aug_{filename}")

        while retries < MAX_RETRIES and not success:
            try:
                # 第一次增强使用基础 Prompt，失败后使用反馈 Prompt
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
                    final_path = os.path.join(root, f"aug_{filename}")
                    os.replace(temp_path, final_path)
                    print(f"✅ {filename} 已增强并执行成功 -> {final_path}")
                    success = True
                else:
                    feedback_msg = error_msg
                    print(f"⚠️ {filename} 执行失败，第 {retries+1} 次重试，错误:\n{error_msg}")
                    retries += 1
                    time.sleep(2 ** min(retries, 5))  # 指数退避，最多 32 秒

            except Exception as e:
                feedback_msg = str(e)
                print(f"⚠️ {filename} LLM 调用异常，第 {retries+1} 次重试: {e}")
                retries += 1
                time.sleep(2 ** min(retries, 5))

        # ❌ 连续失败 10 次 → 不保存任何文件，直接丢弃
        if not success:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            print(f"❌ {filename} 连续 {MAX_RETRIES} 次失败，已放弃")
