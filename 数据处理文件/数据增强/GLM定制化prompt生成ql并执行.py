import os
import time
import subprocess
from zai import ZhipuAiClient

client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

# QL 源文件目录
ql_folder = r"C:\code\ql\python\ql\src\Security\QL_for_Python\Security"
# 数据库目录
database_path = r"C:\code\CQLLM\CodeQL_for_db\db"
# 输出目录（增强后的QL）
output_folder = r"C:\code\ql\python\ql\src\Security\QL_for_Python\Security"
os.makedirs(output_folder, exist_ok=True)

# PROMPT_TEMPLATE = """..."""  # 你的定制化Prompt
PROMPT_TEMPLATE = """
    你是一名资深 CodeQL 安全分析专家。
    接下来我会给你一段现有的 CodeQL 查询代码，请基于它进行数据增强，要求如下：

    ### 增强方式
    1. 代码注释改写（保留逻辑，改变描述方式）
    没有RAG. 变量名替换（保持语义一致性）
    3. 代码片段重组（拆分/合并查询逻辑）
    
    ### 严格约束
    - 不能新增或删除 import，只能保留原始代码里已有的 import。
    - 不能新增谓词 (predicate) 或类定义，只能修改已有逻辑的写法。
    - 不能引入不存在的模块（如 DataFlow），只能使用原始代码里已有的模块。
    - select 子句必须保持相同的输出格式。
    - 保证语法正确，可以在 CodeQL 环境中编译并执行。

    ### 输出格式
    生成的新查询必须符合以下模板：
    /**
     * @name [新漏洞名称]
     * @description [简明描述]
     * @id py/[唯一ID]
     * @kind path-problem
     * @precision low
     * @problem.severity error
     * @security-severity [7.0-9.0]
     * @tags security external/cwe/cwe-[对应CWE编号]
     */

    import python
    import [相关模块1]  // 例如：DataFlow::PathGraph
    import [相关模块2]  // 例如：自定义漏洞流库

    from [SourceNode] source, [SinkNode] sink, [配置节点] config
    where
      [定义source条件] and
      [定义sink条件] and
      [流路径函数](source, sink)
    select sink.getNode(), source, sink,
      "[警告信息模板] $@.", source.getNode(),
      source.toString()

    要求:
    1.输出完整的 CodeQL 查询代码（包含注释头和查询逻辑）。
    没有RAG.保持语法正确，可以直接执行。
    3.至少应用三种增强方式中的两种。
    4.不要输出解释说明，只输出增强后的 QL 代码。
    以下是提供的CodeQL 查询代码:
    {ql_code}
"""

def clean_result(text: str) -> str:
    if "```ql" in text:
        text = text.split("```ql", 1)[1]
    if "```" in text:
        text = text.split("```", 1)[0]
    return text.strip()

def execute_ql(query_path: str) -> bool:
    """执行 QL 查询，返回是否成功"""
    try:
        result = subprocess.run(
            [
                "codeql", "query", "run", query_path,
                "--database", database_path
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8"
        )
        if result.returncode == 0:
            return True
        else:
            print(f"❌ 执行失败: {query_path}\n错误信息:\n{result.stderr}")
            return False
    except Exception as e:
        print(f"⚠️ 执行时发生异常: {e}")
        return False

MAX_RETRIES = 3

for filename in os.listdir(ql_folder):
    if filename.endswith(".ql"):
        ql_path = os.path.join(ql_folder, filename)
        with open(ql_path, "r", encoding="utf-8") as f:
            ql_code = f.read()

        prompt = PROMPT_TEMPLATE.format(ql_code=ql_code)

        retries, success = 0, False
        result = ""

        while retries < MAX_RETRIES and not success:
            try:
                response = client.chat.completions.create(
                    model="glm-4.5",
                    messages=[{"role": "user", "content": prompt}]
                )
                raw = response.choices[0].message.content
                result = clean_result(raw)
                success = True
            except Exception as e:
                retries += 1
                print(f"⚠️ {filename} 调用失败，第 {retries} 次重试: {e}")
                time.sleep(2)

        if not success:
            print(f"❌ {filename} LLM 生成失败，跳过。")
            continue

        # 先保存到临时文件
        temp_path = os.path.join(output_folder, f"temp_aug_{filename}")
        with open(temp_path, "w", encoding="utf-8") as f:
            f.write(result)

        # 验证执行是否成功
        if execute_ql(temp_path):
            final_path = os.path.join(output_folder, f"aug_{filename}")
            os.replace(temp_path, final_path)
            print(f"✅ {filename} 已增强并执行成功 -> {final_path}")
        else:
            os.remove(temp_path)
            print(f"❌ {filename} 执行失败，未保存。")
