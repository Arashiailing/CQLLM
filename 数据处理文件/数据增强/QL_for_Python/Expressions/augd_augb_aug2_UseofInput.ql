/**
 * @name Python 2 中使用了危险的 'input' 函数
 * @description 在 Python 2 环境中，使用内置函数 'input' 可能导致任意代码执行，因为该函数会解析输入为 Python 表达式并执行。
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

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// 识别 Python 2 环境中对危险 input 函数的调用
from DataFlow::CallCfgNode dangerousInputCall
where
  // 确认是对内置 'input' 函数的调用
  dangerousInputCall = API::builtin("input").getACall() and
  // 排除安全的 'raw_input' 函数调用
  not dangerousInputCall = API::builtin("raw_input").getACall() and
  // 限定 Python 2 版本环境
  major_version() = 2
select dangerousInputCall, "The unsafe built-in function 'input' is used in Python 2."