/**
 * @name 'input' function used in Python 2
 * @description Detects usage of the built-in 'input' function in Python 2, which can execute arbitrary code.
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

import python  // Python代码分析核心库
import semmle.python.dataflow.new.DataFlow  // 数据流分析支持库
import semmle.python.ApiGraphs  // API图分析支持库

// 查找Python 2中使用的危险'input'函数调用
from DataFlow::CallCfgNode dangerousInputInvocation
where
  // 版本限制：仅检查Python 2代码
  major_version() = 2 and
  // 函数识别：确认是对内置'input'函数的调用
  dangerousInputInvocation = API::builtin("input").getACall() and
  // 排除条件：确保不是对'raw_input'函数的调用
  dangerousInputInvocation != API::builtin("raw_input").getACall()
select dangerousInputInvocation, "The unsafe built-in function 'input' is used in Python 2."