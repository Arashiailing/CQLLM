/**
 * @name Python 2 元组引发检测
 * @description 识别在 Python 2 中引发元组的代码，这种行为会导致除第一个元素外的所有元素被丢弃
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 查找 Python 2 中的 raise 语句，其中引发的是一个元组表达式
from Raise raiseStmt, DataFlow::LocalSourceNode tupleNode
where
  // 确保代码运行在 Python 2 环境中
  major_version() = 2 and
  // 验证数据流源确实是一个元组表达式
  tupleNode.asExpr() instanceof Tuple and
  // 检查是否存在从元组表达式到 raise 语句异常部分的数据流
  exists(DataFlow::Node exceptionTarget | 
    exceptionTarget.asExpr() = raiseStmt.getException() and
    tupleNode.flowsTo(exceptionTarget)
  )
/* 注意：在 Python 3 中，引发元组会导致 TypeError，这由 IllegalRaise 查询处理。 */
select raiseStmt,
  "引发 $@ 将导致仅第一个元素（递归地）被引发，而所有其他元素将被丢弃。",
  tupleNode, "元组"