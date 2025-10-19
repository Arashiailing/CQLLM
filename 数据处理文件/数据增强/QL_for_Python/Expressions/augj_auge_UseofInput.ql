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

import python  // Python代码分析基础库
import semmle.python.dataflow.new.DataFlow  // 数据流分析功能
import semmle.python.ApiGraphs  // API图分析工具

// 查找Python 2中的危险'input'函数调用
from DataFlow::CallCfgNode dangerousInputCall
where
  // 确认代码运行在Python 2环境
  major_version() = 2
  and
  // 确定是对'input'内置函数的调用，同时排除'raw_input'函数
  dangerousInputCall = API::builtin("input").getACall() and
  not dangerousInputCall = API::builtin("raw_input").getACall()
select dangerousInputCall, "The unsafe built-in function 'input' is used in Python 2."