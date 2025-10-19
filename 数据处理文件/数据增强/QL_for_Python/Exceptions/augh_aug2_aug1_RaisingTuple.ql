/**
 * @name Raising a tuple
 * @description Detects when a tuple is raised as an exception in Python 2, which discards all but the first element
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 查找Python 2环境中引发元组表达式的情况
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // 验证代码在Python 2环境中运行
  major_version() = 2 and
  // 确保数据流源是元组表达式
  tupleSource.asExpr() instanceof Tuple and
  // 检查元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* Note: In Python 3, raising a tuple results in a TypeError, which is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"