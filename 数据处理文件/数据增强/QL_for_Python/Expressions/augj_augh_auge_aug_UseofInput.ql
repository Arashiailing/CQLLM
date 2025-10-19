/**
 * @name Python 2 中不安全的 'input' 函数使用
 * @description 在 Python 2 环境中，内置的 'input()' 函数存在严重安全风险，
 *              因为它会将用户输入直接作为 Python 代码执行，从而可能导致代码注入攻击。
 *              与之相比，'raw_input()' 函数则安全地将用户输入作为字符串返回。
 *              本查询专门用于检测并标记所有使用不安全 'input' 函数的代码位置。
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

from DataFlow::CallCfgNode unsafeInputUsage
where
  // 仅分析 Python 2 代码
  major_version() = 2
  // 检测不安全的 'input' 函数调用
  and unsafeInputUsage = API::builtin("input").getACall()
  // 排除安全的 'raw_input' 函数调用
  and unsafeInputUsage != API::builtin("raw_input").getACall()
select unsafeInputUsage, "检测到 Python 2 中使用了不安全的内置函数 'input'，可能导致代码注入攻击"