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

// 本查询旨在检测Python 2代码中引发元组作为异常的模式
// 在Python 2中，引发元组时仅第一个元素被实际引发，其余元素被丢弃
// 这种行为可能导致开发者意图与实际执行结果不一致
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // 限定为Python 2环境，因为Python 3中引发元组会引发类型错误
  major_version() = 2 and
  // 确认数据流源是一个元组表达式
  tupleSource.asExpr() instanceof Tuple and
  // 验证元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* 提示：Python 3中引发元组会导致类型错误，该情况由IllegalRaise查询覆盖。 */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"