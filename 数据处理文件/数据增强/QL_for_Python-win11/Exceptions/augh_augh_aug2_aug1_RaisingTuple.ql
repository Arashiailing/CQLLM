/**
 * @name Raising a tuple
 * @description Detects when a tuple is raised as an exception in Python 2, which discards all but the first element
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// 查找Python 2环境中引发元组表达式作为异常的情况
// 在Python 2中，引发元组会导致只引发第一个元素（递归地）并丢弃所有其他元素
from Raise exceptionRaiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // 确保代码运行在Python 2环境中
  major_version() = 2 and
  // 验证数据流源是一个元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 检查元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionFlowNode | 
    exceptionFlowNode.asExpr() = exceptionRaiseStmt.getException() and
    tupleExprSource.flowsTo(exceptionFlowNode)
  )
/* Note: In Python 3, raising a tuple results in a TypeError, which is handled by the IllegalRaise query. */
select exceptionRaiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"