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

// 查找 Python 2 环境中对不安全的 'input' 内置函数的调用
from DataFlow::CallCfgNode unsafeInputCall
where
  // 确认当前代码运行在 Python 2 环境中
  major_version() = 2
  and
  // 识别对 'input' 函数的调用，并排除对安全的 'raw_input' 函数的调用
  unsafeInputCall = API::builtin("input").getACall()
  and
  not unsafeInputCall = API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."