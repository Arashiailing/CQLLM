/**
 * @name Python 2 中的不安全 'input' 函数调用
 * @description 检测 Python 2 代码中对内置 'input' 函数的调用。
 *              Python 2 中的 'input()' 函数会将用户输入作为 Python 代码执行，
 *              导致严重的代码注入漏洞。与安全返回字符串的 'raw_input()' 不同，
 *              'input()' 可执行用户提供的任意代码。
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
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析库
import semmle.python.ApiGraphs  // 导入 API 图分析库

// 查找 Python 2 代码中的危险 input 函数调用
from DataFlow::CallCfgNode dangerousInputCall
where
  // 确保代码运行在 Python 2 环境
  major_version() = 2
  // 识别对内置 input 函数的调用
  and dangerousInputCall = API::builtin("input").getACall()
  // 排除安全的 raw_input 函数调用
  and dangerousInputCall != API::builtin("raw_input").getACall()
select dangerousInputCall, "在 Python 2 中使用了危险的内建函数 'input'，可能导致代码注入攻击。"