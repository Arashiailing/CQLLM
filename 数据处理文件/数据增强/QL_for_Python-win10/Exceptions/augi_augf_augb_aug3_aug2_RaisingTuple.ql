/**
 * @name Python 2中元组引发的异常处理问题
 * @description 在Python 2环境中，当使用元组作为异常类型时，只有元组的第一个元素会被递归地用作异常类型，其余元素将被忽略
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* 此查询专门针对Python 2环境，因为Python 3中引发元组会直接导致类型错误 */
from Raise raiseStmt, DataFlow::LocalSourceNode tupleNode
where
  /* 确保运行环境为Python 2 */
  major_version() = 2 and
  /* 识别数据源为元组表达式 */
  tupleNode.asExpr() instanceof Tuple and
  /* 验证元组流向raise语句的异常表达式 */
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleNode.flowsTo(exceptionNode)
  )
select raiseStmt,
  "引发 $@ 将仅使用第一个元素（递归地）并忽略所有其他元素。",
  tupleNode, "元组"