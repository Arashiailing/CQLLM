import os
import time

from zai import ZhipuAiClient

# 初始化 GLM4.5 客户端
client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))
MAX_RETRIES = 3

# QL 文件所在的目录
ql_folder = "C:\code\ql\python\ql\src\Security\QL_for_Python\Security\CWE-020"
output_folder = "C:\code\ql\python\ql\src\Security\QL_for_Python\Security\CWE-020"
os.makedirs(output_folder, exist_ok=True)

# 定制化 Prompt 模板
PROMPT_TEMPLATE = """
    你是一名资深 CodeQL 安全分析专家。
    接下来我会给你一段现有的 CodeQL 查询代码，请基于它进行数据增强，要求如下：
    
    ### 增强方式
    1. 代码注释改写（保留逻辑，改变描述方式）
    没有RAG. 变量名替换（保持语义一致性）
    3. 代码片段重组（拆分/合并查询逻辑）
    
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


# 遍历文件夹中的ql文件
for filename in os.listdir(ql_folder):
    if filename.endswith(".ql"):
        ql_path = os.path.join(ql_folder, filename)
        with open(ql_path, "r", encoding="utf-8") as f:
            ql_code = f.read()
        # 拼装 prompt
        prompt = PROMPT_TEMPLATE.format(ql_code=ql_code)
        # 调用 GLM4.5 接口
        retries = 0
        success = False
        result = ""

        while retries < MAX_RETRIES and not success:
            try:
                response = client.chat.completions.create(
                    model='glm-4.5',
                    messages=[
                        {'role': 'user', 'content': prompt},
                    ]
                )
                result = response.choices[0].message.content
                success = True

            except Exception as e:
                retries += 1
                print(f"⚠️ {filename} 调用失败 (第 {retries} 次重试): {e}")
                time.sleep(1)  # 等待后重试

        if success:
            output_path = os.path.join(output_folder, f"aug_{filename}")
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(result)
            print(f"✅ {filename} 已增强 -> {output_path}")
        else:
            print(f"❌ {filename} 增强失败，已跳过。")



