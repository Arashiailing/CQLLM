/**
 * @name Python 2 不安全的 input 函数检测
 * @description 此查询识别 Python 2 代码中对 'input' 内置函数的危险使用。
 *              Python 2 中的 input 函数会执行用户输入的代码，导致潜在的代码注入漏洞。
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

import python  // Python 代码静态分析核心库
import semmle.python.dataflow.new.DataFlow  // 数据流分析工具
import semmle.python.ApiGraphs  // API 调用图分析工具

// 查找 Python 2 中不安全的 input 函数调用
from DataFlow::CallCfgNode vulnerableInputCall
where
  // 确认是对 input 内置函数的调用
  vulnerableInputCall = API::builtin("input").getACall()
  // 排除对更安全的 raw_input 函数的调用
  and vulnerableInputCall != API::builtin("raw_input").getACall()
  // 限制为 Python 2 环境，因为 Python 3 中的 input 函数是安全的
  and major_version() = 2
select vulnerableInputCall, "在 Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入攻击。"