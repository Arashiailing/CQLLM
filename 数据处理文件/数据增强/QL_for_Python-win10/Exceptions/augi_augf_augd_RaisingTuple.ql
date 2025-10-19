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

// 此查询仅适用于 Python 2 代码分析
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // 确保目标代码为 Python 2 版本
  major_version() = 2 and
  // 验证数据流源节点表示元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 确认元组数据流向异常引发语句
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(exceptionNode)
  )
/* 注意：Python 3 中引发元组会引发类型错误，由 IllegalRaise 查询专门处理 */
select raiseStmt,
  "引发 $@ 将导致只引发第一个元素（递归地），而所有其他元素将被丢弃。",
  tupleExprSource, "元组"