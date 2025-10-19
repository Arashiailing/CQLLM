import requests

url = "http://172.23.215.155:8000/v1/chat/completions"

payload = {
    "model": "qwen",
    "messages": [
        {
            "role": "user",
            "content": """你是一名优秀的 CodeQL 代码助手，能够准确理解并生成可执行的 CodeQL 查询。
请根据以下要求生成查询代码：
能力1：筛选出特定的 CWE 编号。要求：确保查询结果对应 CWE-089（SQL Injection），用于检测 SQL 查询中由用户控制输入构造的 SQL 语句。
能力2：针对特定编程语言生成查询。要求：查询仅适用于 Python 语言的代码。"""
        }
    ]
}

resp = requests.post(url, json=payload)
print(resp.json())
