/**
 * @name Python 2中使用的'input'函数
 * @description 使用了内置函数'input'，在Python 2中，该函数允许执行任意代码。
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

// 检测Python 2中的危险'input'函数调用
from DataFlow::CallCfgNode dangerousInputCall
where
  // 确保目标代码为Python 2版本
  major_version() = 2
  and
  // 识别对'input'函数的调用
  dangerousInputCall = API::builtin("input").getACall()
  and
  // 排除安全的'raw_input'函数调用
  dangerousInputCall != API::builtin("raw_input").getACall()
select dangerousInputCall, "Python 2中使用了不安全的内置函数'input'。"