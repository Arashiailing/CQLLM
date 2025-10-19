/**
 * @name Raising a tuple
 * @description Raising a tuple will result in all but the first element being discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 此查询用于识别在Python 2环境中引发元组表达式的情况
// 在Python 2中，当引发一个元组时，只有第一个元素被实际引发，其余元素被忽略
// 这种行为可能导致意外的结果，因为开发者可能期望整个元组被引发
from Raise raiseExpression, DataFlow::LocalSourceNode tupleNode
where
  // 确认代码运行在Python 2环境下，因为Python 3中引发元组会导致类型错误
  major_version() = 2 and
  // 检查数据流源是否为元组表达式
  tupleNode.asExpr() instanceof Tuple and
  // 验证元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node targetNode | 
    targetNode.asExpr() = raiseExpression.getException() and
    tupleNode.flowsTo(targetNode)
  )
/* 注意：在Python 3中引发元组会导致类型错误，该情况由IllegalRaise查询处理。 */
select raiseExpression,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleNode, "tuple"