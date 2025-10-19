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

// 筛选 Python 2 环境下的危险调用节点
from DataFlow::CallCfgNode inputCallNode
where
  // 限定 Python 2 版本环境
  major_version() = 2 and
  // 检测对 'input' 函数的调用
  inputCallNode = API::builtin("input").getACall() and
  // 排除对 'raw_input' 函数的调用
  not inputCallNode = API::builtin("raw_input").getACall()
select inputCallNode, "The unsafe built-in function 'input' is used in Python 2."