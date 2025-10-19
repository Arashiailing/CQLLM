#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
classify_vulns_zhipu.py

用途：
  - 从表格读取（CSV 或 XLSX）包含 "CWE-id" 和 "Query_id" 的行，
  - 在 code-dir 下查找对应文件（如 CWE-19_chef.py 或包含关键词的文件），
  - 读取文件内容并调用智谱 ZhipuAI (glm-4.5) 对文件进行漏洞类型分类，
  - 将分类结果写回表格的 "Vul-type" 列并输出新的表格。

使用示例：
  export ZAI_API_KEY="your_key_here"
  python classify_vulns_zhipu.py --table input.csv --code-dir /path/to/ql_root --out output.csv

依赖：
  pip install pandas tqdm openpyxl zhipuai
"""

import os
import re
import csv
import time
import logging
import argparse
from pathlib import Path
from typing import List, Optional, Tuple
import pandas as pd
from tqdm import tqdm
from zai import ZhipuAiClient


# -------------------- 配置 --------------------
VUL_TYPES = [
    "CookieInjectionQuery",
    "PathInjectionQuery",
    "TarSlipQuery",
    "TemplateInjectionQuery",
    "CommandInjectionQuery",
    "UnsafeShellCommandConstructionQuery",
    "ReflectedXssQuery",
    "SqlInjectionQuery",
    "LdapInjectionQuery",
    "CodeInjectionQuery",
    "HttpHeaderInjectionQuery",
    "LogInjectionQuery",
    "StackTraceExposureQuery",
    "PamAuthorizationQuery",
    "CleartextLoggingQuery",
    "CleartextStorageQuery",
    "WeakSensitiveDataHashingQuery",
    "UnsafeDeserializationQuery",
    "UrlRedirectQuery",
    "XxeQuery",
    "XpathInjectionQuery",
    "PolynomialReDoSQuery",
    "RegexInjectionQuery",
    "XmlBombQueryQuery",
    "ServerSideRequestForgeryQuery",
    "NoSqlInjectionQuery",
]
# -------------------- 配置 --------------------
client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

# 文件内容最大字符数（超出会截断为 head + tail）
MAX_FILE_CHARS = 24000


logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")


def guess_filename_patterns(cwe: str, query_id: str) -> List[str]:
    """
    根据 CWE 和 Query_id 生成可能的文件名匹配模式。
    处理 Query_id 中可能带的 -cwe-XX 后缀。
    """
    simple = query_id.split("/")[-1] if query_id else ""

    # 去掉尾部类似 -cwe-XX 的部分
    simple = re.sub(r'-cwe-\d+$', '', simple, flags=re.IGNORECASE)

    patterns = [
        f"{cwe}_{simple}.py",
        f"{cwe}_{simple}.*",
        f"{cwe}*{simple}*.py",
        f"{cwe}*{simple}*.*",
    ]
    cwe_alt = cwe.replace("-", "_")
    patterns += [
        f"{cwe_alt}_{simple}.py",
        f"{cwe_alt}*{simple}*.py"
    ]
    return patterns


def find_file_for_row(cwe: str, query_id: str, code_dir: Path) -> Optional[Path]:
    """
    在 code_dir 下搜索符合模式的文件，返回找到的第一个最佳候选（或 None）。
    """
    patterns = guess_filename_patterns(cwe, query_id)
    candidates = []
    for pat in patterns:
        for p in code_dir.rglob(pat):
            if p.is_file():
                candidates.append(p)
    # 宽泛搜索（包含 cwe 和 simple）
    if not candidates:
        simple = query_id.split("/")[-1] if query_id else ""
        for p in code_dir.rglob("*"):
            if not p.is_file():
                continue
            name = p.name.lower()
            if cwe.lower() in name and simple.lower() in name:
                candidates.append(p)
    if not candidates:
        return None
    # 优先选择文件名短且路径较短的
    candidates = sorted(candidates, key=lambda p: (len(p.name), len(str(p))))
    return candidates[0]


# -------------------- 读取并截断文件内容 --------------------
def read_and_truncate(path: Path, max_chars: int = MAX_FILE_CHARS) -> Tuple[str, bool]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    truncated = False
    if len(text) > max_chars:
        head = text[: max_chars // 2]
        tail = text[- (max_chars // 2) :]
        text = head + "\n\n# --- TRUNCATED ---\n\n" + tail
        truncated = True
    return text, truncated


# -------------------- 构建 Prompt --------------------
PROMPT_TEMPLATE = """You are an expert code security classifier.

You will be given the content of a single Python file.判断该文件存在的漏洞类型。 From the following list of vulnerability labels,
determine which labels (if any) apply to this file.

**IMPORTANT — strict output rule**:
- You MUST output exactly one line only.
- If one or more labels apply, output them as a comma-separated list using EXACT label strings from the provided list (case-sensitive), e.g.:
  SqlInjectionQuery, ReflectedXssQuery
- 如果不存在标签中的漏洞类型但是存在漏洞，则输出：不存在标签漏洞
- 如果代码不存在漏洞，则输出：不存在漏洞
- Do not output any other text, explanation, brackets, or quotes.

Vulnerability list (use labels exactly as below):
{vul_list}
如果没有相应的漏洞类型，则选择漏洞类型相似度最高的一个标签。
File metadata:
- file_path: {file_path}
- truncated: {truncated}

Now analyze the file content and follow the strict output rule.

File content:
"""

def build_prompt(file_content: str, file_path: str, truncated: bool) -> str:
    return PROMPT_TEMPLATE.format(
        vul_list=", ".join(VUL_TYPES),
        file_path=file_path,
        truncated=str(truncated),
        file_content=file_content,
    )



def clean_result(s: str) -> str:
    if s is None:
        return ""
    return s.strip()

def call_zhipu_llm(prompt: str) -> str:
    """调用 LLM 生成增强或修复结果"""
    response = client.chat.completions.create(
        model="glm-4.5",
        messages=[{"role": "user", "content": prompt}]
    )
    return clean_result(response.choices[0].message.content)


# -------------------- 主流程：处理表格 --------------------
def process_table(table_path: Path, code_dir: Path, out_path: Path):
    # 读取表格
    if table_path.suffix.lower() in (".xls", ".xlsx"):
        df = pd.read_excel(table_path, dtype=str)
    else:
        df = pd.read_csv(table_path, dtype=str)
    # 遍历
    for idx, row in tqdm(df.iterrows(), total=len(df), desc="Processing rows"):
        cwe = str(row["CWE-id"]).strip()
        qid = str(row["Query_id"]).strip()
        # 查找文件
        file_path = find_file_for_row(cwe, qid, code_dir)
        if file_path is None:
            df.at[idx, "Vul-type"] = "FileNotFound"
            continue

        # 读取文件内容
        content, truncated = read_and_truncate(file_path)
        prompt = build_prompt(content, str(file_path), truncated)

        # 调用智谱模型
        try:
            resp_text = call_zhipu_llm(prompt)
            # 取第一行作为结果
            first_line = resp_text.strip().splitlines()[0].strip() if resp_text.strip() else ""
            first_line = first_line.strip(' "\'')
            # 处理严格规则：如果恰好是中文“不存在漏洞”
            if first_line == "不存在漏洞":
                df.at[idx, "Vul-type"] = first_line
                continue
            # 否则尝试解析为逗号分隔的标签，并且每个标签必须精确匹配 VUL_TYPES
            labels = [lbl.strip() for lbl in first_line.split(",") if lbl.strip()]
            labels_valid = [l for l in labels if l in VUL_TYPES]
            # 只有当解析出的所有非空标签都在 VUL_TYPES 且数量与原标签数量一致时，认为合法
            if labels and len(labels_valid) == len(labels):
                df.at[idx, "Vul-type"] = ", ".join(labels_valid)
            else:
                # 非法响应：保留原始响应以便人工复核
                df.at[idx, "Vul-type"] = f"UnmappedResponse: {first_line}"
        except Exception as e:
                logging.exception("LLM 调用出错，行: %s %s", cwe, qid)
                df.at[idx, "Vul-type"] = f"AIError: {str(e)}"


    # 保存输出
    if out_path.suffix.lower() in (".xls", ".xlsx"):
        df.to_excel(out_path, index=False)
    else:
        df.to_csv(out_path, index=False, quoting=csv.QUOTE_MINIMAL)
    logging.info("Saved output to %s", out_path)


# -------------------- CLI --------------------
def main():
    # 固定参数配置
    table_path = Path(r"C:\code\CQLLM\experience\第九轮.xlsx")
    code_dir = Path(r"C:\code\CQLLM\experience\Python_CWE_Bench")
    out_path = table_path.parent / f"output_{table_path.name}"

    if not table_path.exists():
        raise FileNotFoundError(f"table not found: {table_path}")
    if not code_dir.exists():
        raise FileNotFoundError(f"code dir not found: {code_dir}")

    process_table(table_path, code_dir, out_path)


if __name__ == "__main__":
    main()
