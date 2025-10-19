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

// 查找Python 2环境中将元组作为异常引发的语句
from Raise raiseStatement, DataFlow::LocalSourceNode tupleExprSource
where
  // 确保代码运行在Python 2环境中，此行为在Python 3中会引发TypeError
  major_version() = 2 and
  // 验证数据流源确实是一个元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 检查元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionArgNode | 
    exceptionArgNode.asExpr() = raiseStatement.getException() and
    tupleExprSource.flowsTo(exceptionArgNode)
  )
/* Note: In Python 3, raising a tuple results in a TypeError, which is handled by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"