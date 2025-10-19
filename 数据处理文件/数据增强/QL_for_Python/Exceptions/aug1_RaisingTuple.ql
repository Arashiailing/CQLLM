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

// 查找Python 2代码中引发元组的语句
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // 确保代码运行在Python 2环境中
  major_version() = 2 and
  // 检查数据流源是一个元组表达式
  tupleSource.asExpr() instanceof Tuple and
  // 验证元组流向异常表达式
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* 在Python 3中引发元组是类型错误，因此由IllegalRaise查询处理。 */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"