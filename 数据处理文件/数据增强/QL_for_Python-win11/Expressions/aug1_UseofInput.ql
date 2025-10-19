/**
 * @name Detection of unsafe 'input' function in Python 2
 * @description Identifies usage of the built-in 'input' function which, in Python 2, 
 *              can execute arbitrary code provided as input, posing a security risk.
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

import python  // 导入Python分析库，用于Python代码静态分析
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析功能
import semmle.python.ApiGraphs  // 导入API图分析工具

// 查找Python 2中不安全的input函数调用
from DataFlow::CallCfgNode unsafeInputCall
where
  // 限定为Python 2版本环境
  major_version() = 2 and
  // 定位到内置input函数的调用
  unsafeInputCall = API::builtin("input").getACall() and
  // 排除raw_input函数调用，因为它在Python 2中是安全的
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."  // 报告不安全的input函数调用