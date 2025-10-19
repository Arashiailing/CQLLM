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

// 检测Python 2环境中引发元组表达式的潜在问题
// 在Python 2中，raise语句引发元组时仅保留第一个元素，其余元素被忽略
// 这种行为与开发者预期不符，可能导致意外结果
from Raise raiseStatement, DataFlow::LocalSourceNode tupleExprSource
where
  // 确保代码运行在Python 2环境（Python 3中引发元组会导致类型错误）
  major_version() = 2 and
  // 验证数据流源是否为元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 检查元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionExprNode | 
    exceptionExprNode.asExpr() = raiseStatement.getException() and
    tupleExprSource.flowsTo(exceptionExprNode)
  )
/* 注意：Python 3中引发元组会导致类型错误，该情况由IllegalRaise查询处理 */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"