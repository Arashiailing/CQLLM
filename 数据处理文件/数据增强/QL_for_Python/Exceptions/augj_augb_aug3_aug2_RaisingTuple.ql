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

/* 此问题仅存在于Python 2环境中；Python 3将元组引发视为类型错误 */
from Raise raiseNode, DataFlow::LocalSourceNode tupleSource
where
  /* 验证当前Python版本为2 */
  major_version() = 2 and
  /* 确认数据源是元组类型表达式 */
  tupleSource.asExpr() instanceof Tuple and
  /* 检查是否存在从元组到异常表达式的数据流 */
  exists(DataFlow::Node exceptionTarget | 
    exceptionTarget.asExpr() = raiseNode.getException() and
    tupleSource.flowsTo(exceptionTarget)
  )
select raiseNode,
  "引发 $@ 将仅使用第一个元素（递归地）并忽略所有其他元素。",
  tupleSource, "元组"