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

// 检测Python 2代码中将元组作为异常对象引发的语句
// 这种行为在Python 3中会导致TypeError，但在Python 2中只会引发元组的第一个元素
from Raise raiseStatement, DataFlow::LocalSourceNode tupleOrigin
where
  // 确认代码在Python 2环境下运行
  major_version() = 2 and
  // 验证数据流源确实是一个元组表达式
  tupleOrigin.asExpr() instanceof Tuple and
  // 检查从元组到raise语句异常部分的数据流
  exists(DataFlow::Node exceptionTarget | 
    exceptionTarget.asExpr() = raiseStatement.getException() and
    tupleOrigin.flowsTo(exceptionTarget)
  )
/* Note: Python 3中引发元组会导致TypeError，这由IllegalRaise查询处理。 */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"