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

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// 检测 Python 2 环境中的不安全 input 调用
from DataFlow::CallCfgNode unsafeInputCall
where
  // 确保运行环境为 Python 2
  major_version() = 2
  and
  // 定位对内置 'input' 函数的调用
  unsafeInputCall = API::builtin("input").getACall()
  and
  // 排除安全的 'raw_input' 函数调用
  not unsafeInputCall = API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."