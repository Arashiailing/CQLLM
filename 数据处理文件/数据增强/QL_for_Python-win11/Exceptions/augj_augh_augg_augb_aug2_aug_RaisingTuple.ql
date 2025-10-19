/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple results in only the first element being raised as an exception,
 *              while all other elements are silently discarded. This can lead to unexpected behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// 该查询检测使用元组表达式作为异常的raise语句
// 在Python 2中，这种行为会导致只有元组的第一个元素被抛出，
// 而在Python 3中，这会引发TypeError
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // 限制分析范围仅限于Python 2代码库
  major_version() = 2 and
  // 确保源节点代表元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 验证元组表达式通过数据流传递到异常抛出点
  exists(DataFlow::Node exceptionDestNode |
    exceptionDestNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(exceptionDestNode)
  )
/* 注意：此行为是Python 2特有的。在Python 3中，抛出元组会导致TypeError，
   该错误由IllegalRaise查询覆盖 */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"