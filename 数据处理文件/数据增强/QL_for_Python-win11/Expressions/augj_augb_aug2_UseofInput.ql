/**
 * @name Python 2 中使用了 'input' 函数
 * @description 在 Python 2 中，内置函数 'input' 会将用户输入作为 Python 代码执行，
 *              这可能导致任意代码执行漏洞。此查询检测 Python 2 代码中对 'input' 函数的使用。
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

// 查找不安全的 input 函数调用
from DataFlow::CallCfgNode unsafeInputCall
where
  // 确保在 Python 2 环境中
  major_version() = 2 and
  // 检测对 'input' 内置函数的调用
  unsafeInputCall = API::builtin("input").getACall() and
  // 排除对安全的 'raw_input' 函数的调用
  not unsafeInputCall = API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."