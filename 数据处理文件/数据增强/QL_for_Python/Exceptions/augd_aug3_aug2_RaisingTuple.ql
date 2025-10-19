/**
 * @name Python 2 中的元组引发异常
 * @description 在 Python 2 中，引发元组作为异常时只会使用第一个元素，其余元素将被忽略
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* 此问题特定于 Python 2；Python 3 将元组引发视为类型错误 */
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // 限定为 Python 2 环境
  major_version() = 2 and
  // 确保源节点是一个元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 检查元组是否流向了 raise 语句的异常表达式
  exists(DataFlow::Node raisedExceptionNode | 
    raisedExceptionNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(raisedExceptionNode)
  )
select raiseStmt,
  "引发 $@ 将仅使用第一个元素（递归地）并忽略所有其他元素。",
  tupleExprSource, "元组"