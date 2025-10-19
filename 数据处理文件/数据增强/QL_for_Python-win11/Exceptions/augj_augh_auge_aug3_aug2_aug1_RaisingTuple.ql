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

// 此查询专门用于检测Python 2代码中将元组作为异常引发的潜在问题
// 在Python 2中，引发元组时只有第一个元素会被实际引发，其余元素会被忽略
// 这种特殊行为可能导致开发者的编码意图与实际执行结果不一致
from Raise raiseStatement, DataFlow::LocalSourceNode tupleExprSource
where
  // 验证数据流源确实是一个元组表达式
  tupleExprSource.asExpr() instanceof Tuple and
  // 确保代码运行在Python 2环境下
  // 注意：在Python 3中，引发元组会引发TypeError，这种情况由IllegalRaise查询处理
  major_version() = 2 and
  // 检查元组表达式是否流向raise语句的异常部分
  exists(DataFlow::Node exceptionFlowNode | 
    exceptionFlowNode.asExpr() = raiseStatement.getException() and
    tupleExprSource.flowsTo(exceptionFlowNode)
  )
/* 注意：在Python 3中，引发元组会导致TypeError异常，这种情况由IllegalRaise查询覆盖。 */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"