/**
 * @name Python 2中引发元组的问题
 * @description 在Python 2中，引发元组只会使用第一个元素（递归地）并丢弃所有其他元素
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* 此问题特定于Python 2环境；Python 3将元组引发视为类型错误 */
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  /* 确保运行环境为Python 2 */
  major_version() = 2 and
  /* 确认数据源是元组表达式 */
  tupleExprSource.asExpr() instanceof Tuple and
  /* 验证从元组到异常表达式的数据流路径 */
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(exceptionNode)
  )
select raiseStmt,
  "引发 $@ 将仅使用第一个元素（递归地）并忽略所有其他元素。",
  tupleExprSource, "元组"