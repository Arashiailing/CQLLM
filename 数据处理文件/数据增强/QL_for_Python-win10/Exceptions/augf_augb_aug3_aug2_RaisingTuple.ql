/**
 * @name Python 2中元组引发的异常处理问题
 * @description 在Python 2环境中，当使用元组作为异常类型时，只有元组的第一个元素会被递归地用作异常类型，其余元素将被忽略
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* 本查询仅适用于Python 2环境，因为在Python 3中，直接引发元组会引发类型错误 */
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSource
where
  /* 检查是否为Python 2环境 */
  major_version() = 2 and
  /* 确认数据源是元组表达式 */
  tupleSource.asExpr() instanceof Tuple and
  /* 检查元组是否流向raise语句的异常表达式 */
  exists(DataFlow::Node exceptionExprNode | 
    exceptionExprNode.asExpr() = raiseStatement.getException() and
    tupleSource.flowsTo(exceptionExprNode)
  )
select raiseStatement,
  "引发 $@ 将仅使用第一个元素（递归地）并忽略所有其他元素。",
  tupleSource, "元组"