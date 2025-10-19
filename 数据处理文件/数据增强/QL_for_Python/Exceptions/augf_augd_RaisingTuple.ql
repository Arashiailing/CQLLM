/**
 * @name Python 2 元组引发异常
 * @description 在 Python 2 中引发元组异常将导致除第一个元素外的所有元素被丢弃
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 确保我们分析的是 Python 2 代码
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSource
where
  major_version() = 2 and
  // 验证源节点表示一个元组表达式
  tupleSource.asExpr() instanceof Tuple and
  // 确认从元组到引发异常的数据流
  exists(DataFlow::Node raisedException |
    raisedException.asExpr() = raiseStatement.getException() and
    tupleSource.flowsTo(raisedException)
  )
/* 在 Python 3 中引发元组是类型错误，由 IllegalRaise 查询处理。 */
select raiseStatement,
  "引发 $@ 将导致只引发第一个元素（递归地），而所有其他元素将被丢弃。",
  tupleSource, "元组"