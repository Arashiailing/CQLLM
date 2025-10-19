import re

from ragflow_sdk import RAGFlow

# ===============================
# 初始化 RAGFlow 对象
# ===============================
rag_object = RAGFlow(
    api_key="ragflow-AzZTE4ODQ4OTE3MTExZjBiMDk0YWE2YW",
    base_url="http://172.23.215.155:9380/"
)

# ===============================
# 获取已经创建的聊天助手（名字为 CQLLM）
# ===============================
assistants = rag_object.list_chats(name="CQLLM")
if not assistants:
    raise Exception("找不到名为 CQLLM 的助手，请先在 RAGFlow 上创建。")

assistant = assistants[0]

# ===============================
# 创建会话
# ===============================
session = assistant.create_session("一名优秀的 CodeQL 代码助手")

# ===============================
# 固定 prompt（一次性 RAG+LLM 请求）
# ===============================
prompt = (
    "请编写一个CodeQL查询，该查询需要满足以下要求：要求1：查询结果中的CWE编号为CWE-20,CWE-20: Improper Input Validation。要求2：查询结果中的查询ID必须为py/stringutils。要求3：关于该CWE-20的描述是：The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly. 。请编写相应的CodeQL查询代码，只需要给出ql代码，不需要给出描述信息。"
)

# ===============================
# 调用一次 ask 方法，收集结果
# ===============================
result = ""
for ans in session.ask(prompt, stream=True):
    result = ans.content  # 每次迭代 result 都是完整累积结果

# 去掉 <think></think> 标签及其内容
print(result)
clean_result = re.sub(r"<think>.*?</think>", "", result, flags=re.DOTALL).strip()
# 保存到 .ql 文件
with open("output_query.ql", "w", encoding="utf-8") as f:
    f.write(clean_result)

print("已保存生成的 CodeQL 查询到 output_query.ql")
