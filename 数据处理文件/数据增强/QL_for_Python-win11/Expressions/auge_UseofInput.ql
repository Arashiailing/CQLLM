/**
 * @name 'input' function used in Python 2
 * @description The built-in function 'input' is used which, in Python 2, can allow arbitrary code to be run.
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

// 查找Python 2中的不安全'input'函数调用
from DataFlow::CallCfgNode unsafeInputUsage
where
  // 确保分析Python 2代码
  major_version() = 2
  and
  // 识别对'input'函数的调用
  unsafeInputUsage = API::builtin("input").getACall()
  and
  // 排除安全的'raw_input'函数调用
  unsafeInputUsage != API::builtin("raw_input").getACall()
select unsafeInputUsage, "The unsafe built-in function 'input' is used in Python 2."