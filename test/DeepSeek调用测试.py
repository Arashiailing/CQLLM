import requests
import json
import pandas as pd
from tqdm import tqdm
import time

file_names = ['C:\code\CQLLM-Python10\CQLLM-Python10\最终版prompt.csv']

def load_excel_rows(file_path):
    df = pd.read_csv(file_path)
    return df


def read_codeql_functions(file_path):
    with open(file_path, 'r') as file:
        functions_content = file.read()
    return functions_content

# 模型
model = 'ds'
# 目标URL
url = 'http://172.23.215.155:7861/chat/kb_chat'
OUTPUT_DIR = r"C:\code\CQLLM\对比试验\ds-ft\ql_output"
os.makedirs(OUTPUT_DIR, exist_ok=True)
# ================= 工具函数 =================
def clean_codeql(raw_text: str) -> str:
    """清理模型输出，去掉 <think> 标签并提取 codeql/ql 代码块"""
    if not raw_text:
        return ""
    no_think = re.sub(r"<think>.*?</think>", "", raw_text, flags=re.DOTALL | re.IGNORECASE).strip()
    code_blocks = re.findall(r"```(?:\s*(?:codeql|ql)\s*)\n?(.*?)```", no_think, flags=re.DOTALL | re.IGNORECASE)
    if not code_blocks:
        code_blocks = re.findall(r"```\s*(.*?)```", no_think, flags=re.DOTALL)
    final = code_blocks[0].strip() if code_blocks else no_think
    final = re.sub(r"\n{3,}", "\n\n", final).strip()
    return final

def sanitize_filename(name: str) -> str:
    return re.sub(r"[<>:\"/\\|?*\n\r\t]+", "_", name)

# ================= 主流程 =================
def generate_codeql_from_csv(csv_file):
    df = pd.read_csv(csv_file)

    # 读取限制依赖库
    with open('CodeQL-for-python-函数集.txt', 'r', encoding='utf-8') as f:
        codeql_functions = f.read().strip()

    for idx, row in tqdm(df.iterrows(), total=len(df), desc="生成 CodeQL 查询"):
        # 构造 Prompt
        prompt_content = (
            f"请编写一个检测 {row['CWE-id']} : {row['Vul-type']} 漏洞的 CodeQL 查询代码：\n"
            f"@name {row['Name']}\n"
            f"@description {row['Description']}\n"
            f"@id {row['Query_id']}\n\n"
            f"请编写相应的 CodeQL 查询代码，只需要给出 ql 代码，不需要给出描述信息。\n"
            f"可使用的 CodeQL 依赖库如下：{codeql_functions}"
        )

def send_to_LLMs_qwen3(file_names):
    # 要发送的数据
    for file_name in tqdm(file_names, desc='Processing files'):
        excel_file_path = file_name
        try:
            df = load_excel_rows(excel_file_path)
        except FileNotFoundError:
            print(f"File not found: {excel_file_path}")
            continue


        codeql_functions = read_codeql_functions('CodeQL-for-python-函数集.txt')

        for index, row in tqdm(df.iterrows(), desc=f'Processing {file_name}', total=len(df)):
            # 构造提示内容
            data = {
                "query": prompt_content,
                "mode": "local_kb",
                "kb_name": "C",
                "top_k": 3,
                "score_threshold": 2,
                "history": [
                    {
                        "content": "你是一个优秀的CodeQL代码助手，能够很好的理解并解释CodeQL，请编写一个CodeQL查询，该查询需要满足以下能力要求：能力1：能够筛选出特定的CWE编号。要求：确保查询结果中的CWE编号为'20'。能力2：能够针对特定的编程语言生成CodeQL语句。要求：查询应限定在'python'语言编写的代码中。能力3：能够识别特定的查询ID。要求：查询结果中的查询ID必须为'untrusted-data-to-external-api'。能力4：获取CWE描述。要求：应根据'Data provided remotely is used in this external API without sanitization, which could be a security risk.'的CWE描述生成CodeQL语句。请根据以上能力要求，编写相应的CodeQL查询代码。",
                        "role": "user"
                    },
                    {
                        "content": """
                    // 定义不安全的外部API调用
                    import python
                    import ExternalAPIs

                    from ExternalApiUsedWithUntrustedData externalApi
                    select externalApi, count(externalApi.getUntrustedDataNode()) as numberOfUses,
                      externalApi.getNumberOfUntrustedSources() as numberOfUntrustedSources order by
                        numberOfUntrustedSources desc
                      """,
                        "role": "assistant"
                    },
                ],
                "stream": False,
                "model": model,
                "temperature": 1,
                "max_tokens": 2048,
                "prompt_name": "default",
                "return_direct": False
            }

            # 设置请求头
            headers = {
                'accept': 'application/json',
                'Content-Type': 'application/json',
            }

            try:
                # 发送POST请求并设置超时时间为120秒
                response = requests.post(url, data=json.dumps(data), headers=headers, stream=True, timeout=120)
                response.encoding = 'utf-8'
                full_response = response.text
                print(full_response)

                # 处理流式响应
                # chunks = []
                # for chunk in response.iter_content(chunk_size=1024):
                #     if chunk:
                #         try:
                #             chunks.append(chunk.decode('utf-8'))
                #         except UnicodeDecodeError as ude:
                #             print(f"Unicode Decode Error for row {index}, chunk position: {len(chunks)}: {str(ude)}")
                #             chunks.append(chunk.decode('latin1'))  # 使用latin1解码作为替代方案
                #
                # full_response = ''.join(chunks)




            except requests.exceptions.ChunkedEncodingError as ex:
                print(f"Chunked Encoding Error for row {index}: {str(ex)}")
                df.at[index, 'Response'] = str(ex)
            except requests.exceptions.RequestException as e:
                print(f"Request failed for row {index}: {e}")
                df.at[index, 'Response'] = str(e)

                # 保存到文件
                clean_query_id = sanitize_filename(row['Query_id'].replace('py/', ''))
                filename = f"{row['CWE-id']}-{clean_query_id}.ql"
                output_path = os.path.join(OUTPUT_DIR, filename)
                with open(output_path, "w", encoding="utf-8") as f:
                    f.write(codeql_clean)

            # 立即保存当前状态到Excel文件
            # df.to_excel(excel_file_path, index=False)
if __name__ == '__main__':
    send_to_LLMs_qwen3(file_names)



