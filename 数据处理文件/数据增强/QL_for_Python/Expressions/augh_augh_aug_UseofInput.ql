/**
 * @name Python 2 中潜在不安全的 'input' 函数使用
 * @description 检测 Python 2 中内置 'input' 函数的使用，该函数可以执行任意代码。
 *              在 Python 2 中，'input()' 会将用户输入作为 Python 代码求值，
 *              允许恶意用户注入任意代码，导致严重的安全漏洞。
 *              相比之下，'raw_input()' 安全地将输入作为字符串返回。
 * @kind problem
 * @tags security
 *       correctness
 *       security/cwe/cwe-94
 *       security/cwe/cwe-95
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/use-of-input
 */

import python  // 导入用于分析 Python 代码的 Python 库
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析库
import semmle.python.ApiGraphs  // 导入 API 图分析库

// 从数据流分析库中选择调用配置节点
from DataFlow::CallCfgNode riskyInputCall
where
  // 限制分析范围为 Python 2
  major_version() = 2 and
  // 识别对不安全的 'input' 内置函数的调用
  riskyInputCall = API::builtin("input").getACall() and
  // 排除安全的 'raw_input' 函数调用
  riskyInputCall != API::builtin("raw_input").getACall()
select riskyInputCall, "Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入。"