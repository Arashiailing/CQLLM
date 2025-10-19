import re
import pandas as pd
from ragflow_sdk import RAGFlow
import os

# ===============================
# 初始化 RAGFlow 对象
# ===============================
rag_object = RAGFlow(
    api_key="ragflow-AzZTE4ODQ4OTE3MTExZjBiMDk0YWE2YW",
    base_url="http://172.23.215.155:9380/"
)

# 获取已经创建的聊天助手（名字为 CQLLM）
assistants = rag_object.list_chats(name="qwen2.5")
if not assistants:
    raise Exception("找不到名为 CQLLM 的助手，请先在 RAGFlow 上创建。")

assistant = assistants[0]



# ===============================
# 读取 CWE CSV
# ===============================
csv_file = r"C:\code\CQLLM-Python10\CQLLM-Python10\最终版prompt.csv"  # 包含 CWE-id, name, description, Query_id
df = pd.read_csv(csv_file)

# 输出目录
# output_dir = r"C:\code\CQLLM\消融实验\1\ql_outputs"
output_dir = r"C:\code\CQLLM-Python10\CQLLM-Python10\给老师看过后\消融实验\qwen2.5-7B-noft-RAG\ql_outputs"
os.makedirs(output_dir, exist_ok=True)


# ===============================
# 遍历每一行，生成 prompt 并调用 RAGFlow
# ===============================
for idx, row in df.iterrows():
    prompt = (
        f"请编写一个检测{row['CWE-id']}:{row['Vul-type']}漏洞的CodeQL查询代码：@name {row['Name']} "
        f"@description {row['Description']} "
        f"@id {row['Query_id']} "
        f"请编写相应的CodeQL查询代码，只需要给出ql代码，不需要给出描述信息。仅可使用知识库”ql代码仅可import的依赖库集合.txt“文件中提供的依赖库。使用依赖库时，只能使用查询到的相关模块/类/函数/谓词等。"
    )

    print(f"[{idx+1}/{len(df)}] 正在生成 {row['Query_id']} 对应的 CodeQL 查询...")
    # 创建会话
    session = assistant.create_session("一名优秀的 CodeQL 代码助手")

    # 调用 RAGFlow
    result = ""
    for ans in session.ask(prompt, stream=True):
        result = ans.content  # 每次迭代 result 都是完整累积结果

    # 去掉 <think></think> 标签及其内容
    clean_result = re.sub(r"<think>.*?</think>", "", result, flags=re.DOTALL).strip()
    # 提取 codeql 或 ql 代码块
    code_blocks = re.findall(r"```(?:codeql|ql)?\s*(.*?)```", clean_result, flags=re.DOTALL | re.IGNORECASE)
    if code_blocks:
        clean_result = "\n\n".join(block.strip() for block in code_blocks)
    # 如果没有 code 块，保持原文
    else:
        clean_result = clean_result.strip()

    # 文件名处理：加上 CWE-id 前缀，并去掉 py/ 前缀
    clean_query_id = row['Query_id'].replace('py/', '')  # 去掉 py/ 前缀
    filename = f"{row['CWE-id']}-{clean_query_id}.ql"
    output_path = os.path.join(output_dir, filename)

    # 保存到 .ql 文件
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(clean_result)

    print(f"已保存 {filename}")

print("全部 CodeQL 查询生成完成！")
