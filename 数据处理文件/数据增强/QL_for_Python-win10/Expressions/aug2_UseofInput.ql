/**
 * @name Python 2 中使用了 'input' 函数
 * @description 检测到使用了内置函数 'input'，在 Python 2 中，该函数可能导致任意代码执行。
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

// 从数据流分析库中选择调用配置节点
from DataFlow::CallCfgNode unsafeInputCall
where
  // 确保仅在Python 2版本中进行分析
  major_version() = 2 and
  // 查找对内置函数'input'的调用
  unsafeInputCall = API::builtin("input").getACall() and
  // 确保不是对'raw_input'的调用
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."  // 选择并报告不安全的'input'函数调用