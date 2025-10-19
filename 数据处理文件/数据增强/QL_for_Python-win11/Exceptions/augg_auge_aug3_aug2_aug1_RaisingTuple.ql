/**
 * @name Raising a tuple
 * @description Detects code patterns where a tuple is raised as an exception in Python 2,
 *              causing all but the first element to be discarded.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 本查询旨在检测Python 2环境中将元组作为异常抛出的代码模式
// 在Python 2中，抛出元组时只有第一个元素会被实际抛出，其余元素将被忽略
// 这种行为可能违背开发者的预期，因为他们可能期望整个元组被抛出
from Raise raiseExpr, DataFlow::LocalSourceNode tupleSource
where
  // 限定查询范围为Python 2环境，因为Python 3中抛出元组会引发类型错误
  major_version() = 2 and
  // 确认数据流源头是一个元组表达式
  tupleSource.asExpr() instanceof Tuple and
  // 验证元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseExpr.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* 注意：Python 3中抛出元组会导致类型错误，该情况由IllegalRaise查询处理。 */
select raiseExpr,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"