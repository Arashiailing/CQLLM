/**
 * @name Raising a tuple
 * @description In Python 2, raising a tuple causes all elements except the first to be discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 检测Python 2代码中引发元组表达式的情况
from Raise raiseStatement, DataFlow::LocalSourceNode tupleOrigin
where
  // 确认代码运行在Python 2环境中
  major_version() = 2 and
  // 确认数据流源是一个元组表达式
  tupleOrigin.asExpr() instanceof Tuple and
  // 检查元组是否流向异常表达式
  exists(DataFlow::Node exceptionFlowNode | 
    exceptionFlowNode.asExpr() = raiseStatement.getException() and
    tupleOrigin.flowsTo(exceptionFlowNode)
  )
/* 注意：在Python 3中，引发元组会导致类型错误，这种情况由IllegalRaise查询处理。 */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"