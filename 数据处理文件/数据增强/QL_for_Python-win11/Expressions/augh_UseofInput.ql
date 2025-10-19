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

import python  // 导入Python库，用于分析Python代码
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析库
import semmle.python.ApiGraphs  // 导入API图分析库

// 查找Python 2中使用的内置'input'函数调用
from DataFlow::CallCfgNode unsafeInputCall
where
  // 限制为Python 2版本
  major_version() = 2 and
  // 确保是对内置'input'函数的调用
  unsafeInputCall = API::builtin("input").getACall() and
  // 排除对'raw_input'函数的调用
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."