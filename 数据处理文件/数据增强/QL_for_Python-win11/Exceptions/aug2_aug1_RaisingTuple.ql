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
from Raise raiseStatement, DataFlow::LocalSourceNode tupleExprSource
where
  // 确认代码运行在Python 2环境下
  major_version() = 2 and
  // 验证数据流源是一个元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 确认元组表达式流向raise语句的异常部分
  exists(DataFlow::Node exceptionFlowNode | 
    exceptionFlowNode.asExpr() = raiseStatement.getException() and
    tupleExprSource.flowsTo(exceptionFlowNode)
  )
/* Python 3中引发元组会导致类型错误，该情况由IllegalRaise查询处理。 */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"