/**
 * @name Raising a tuple
 * @description Raising a tuple will result in all but the first element being discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// 从Raise语句中选择raiseNode，并从DataFlow::LocalSourceNode类中选择tupleOrigin
from Raise raiseNode, DataFlow::LocalSourceNode tupleOrigin
where
  // 检查是否存在一个异常节点，该节点的表达式等于raiseNode.getException()
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseNode.getException() and
    tupleOrigin.flowsTo(exceptionNode)
  ) and
  // 确保tupleOrigin的表达式是一个Tuple类型
  tupleOrigin.asExpr() instanceof Tuple and
  // 此问题仅适用于Python 2，因为在Python 3中引发元组是类型错误
  major_version() = 2
/* 在Python 3中引发元组是类型错误，因此由IllegalRaise查询处理。 */
select raiseNode,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"