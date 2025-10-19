/**
 * @name Python 2 中不安全的 'input' 函数使用
 * @description 检测 Python 2 代码中对内置函数 'input' 的调用。
 *              在 Python 2 中，'input()' 会将用户输入作为 Python 代码执行，从而造成严重的代码注入漏洞。
 *              这与 'raw_input()' 不同，后者安全地将用户输入作为字符串返回而不执行。
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

import python  // 导入 Python 代码分析库
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析模块
import semmle.python.ApiGraphs  // 导入 API 图分析模块

// 识别 Python 2 环境中的危险 input 调用
from DataFlow::CallCfgNode vulnerableInputInvocation
where
  // 限定分析范围为 Python 2 代码库
  major_version() = 2
  and
  // 匹配对不安全的 'input' 内置函数的调用
  vulnerableInputInvocation = API::builtin("input").getACall()
  and
  // 排除安全的 'raw_input' 调用
  vulnerableInputInvocation != API::builtin("raw_input").getACall()
select vulnerableInputInvocation, "在 Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入攻击。"