import os
from xinference.client import RESTfulClient

# -------------------- 配置 --------------------
client = RESTfulClient("http://172.23.215.155:9997")
model = client.get_model("qwen3")  # 启动模型时 --model-uid 的值

# -------------------- 工具函数 --------------------
def clean_result(text: str) -> str:
    """清理 LLM 输出的 ```ql 包裹"""
    if not text:
        return ""
    if "```ql" in text:
        text = text.split("```ql", 1)[1]
    if "```" in text:
        text = text.split("```", 1)[0]
    return text.strip()

def call_llm(prompt: str) -> str:
    """调用本地 xinference 模型生成增强结果"""
    response = model.chat(messages=[{"role": "user", "content": prompt}])

    # 提取内容
    if isinstance(response, dict) and "choices" in response:
        content = response["choices"][0]["message"]["content"]
    else:
        content = str(response)
    return clean_result(content)

# -------------------- 待增强的 QL 文件 --------------------
ql_file = r"C:\code\ql\python\ql\src\Security\CWE-020\test\CookieInjection.ql"  # 替换为你的文件
with open(ql_file, "r", encoding="utf-8") as f:
    ql_code = f.read()

# -------------------- 构建增强 Prompt --------------------
prompt = f"""
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

# -------------------- 调用模型 --------------------
enhanced_code = call_llm(prompt)
print("🔹 增强后的 QL 代码:\n", enhanced_code)

# -------------------- 保存到文件 --------------------
dir_path = os.path.dirname(ql_file)
base_name = os.path.basename(ql_file)
aug_path = os.path.join(dir_path, f"aug_{base_name}")

with open(aug_path, "w", encoding="utf-8") as f:
    f.write(enhanced_code)

print(f"✅ 增强后的文件已保存: {aug_path}")
