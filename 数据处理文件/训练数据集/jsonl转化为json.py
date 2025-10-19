import json

input_file = r"C:\code\CQLLM\v2.0\RAG知识库处理\modules_rag.jsonl"
output_file = r"C:\code\CQLLM\v2.0\RAG知识库处理\modules_rag.json"

data = []
with open(input_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if line:
            data.append(json.loads(line))

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
