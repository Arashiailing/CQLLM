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

// 检测在Python 2环境中使用元组作为异常引发的问题
// 在Python 2中，当引发一个元组时，只有第一个元素被实际引发，其余元素被忽略
// 这可能导致意外的行为，因为开发者可能期望整个元组被引发
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // 确保代码运行在Python 2环境下，因为Python 3中引发元组会导致类型错误
  major_version() = 2 and
  // 验证数据流源是一个元组表达式
  tupleSource.asExpr() instanceof Tuple and
  // 检查元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* 注意：在Python 3中引发元组会导致类型错误，该情况由IllegalRaise查询处理。 */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"