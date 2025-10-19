from xinference.client import RESTfulClient

client = RESTfulClient("http://172.23.215.155:9997")
# 注意：my-llm是参数`--model-uid`指定的值
model = client.get_model("qwen3")
print(model.chat(
    messages=[
        {"role": "user", "content": "你好，请介绍一下你自己。"}
    ]
))

