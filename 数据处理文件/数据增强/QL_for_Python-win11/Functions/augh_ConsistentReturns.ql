/**
 * @name 混合显式返回与隐式返回（fall through）
 * @description 当函数同时包含显式返回（非None值）和隐式返回时，通常表示逻辑错误，
 *              因为隐式返回总是返回None值，可能导致意外行为。
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// 判断函数是否包含显式返回非None值的语句
predicate contains_explicit_non_none_return(Function targetFunction) {
  // 存在返回语句：作用域属于当前函数 且 返回值存在 且 返回值不是None
  exists(Return retStmt |
    retStmt.getScope() = targetFunction and
    exists(Expr returnValue | returnValue = retStmt.getValue() | not returnValue instanceof None)
  )
}

// 判断函数是否包含隐式返回（fall through）
predicate contains_implicit_return(Function targetFunction) {
  // 条件1：存在可到达的fallthrough节点（函数末尾未显式返回）
  exists(ControlFlowNode fallthroughNode |
    fallthroughNode = targetFunction.getFallthroughNode() and 
    not fallthroughNode.unlikelyReachable()
  )
  or
  // 条件2：存在无返回值的显式return语句（等价于隐式返回None）
  exists(Return retStmt | 
    retStmt.getScope() = targetFunction and 
    not exists(retStmt.getValue())
  )
}

// 查询同时满足两个条件的函数：包含显式非None返回 + 包含隐式返回
from Function targetFunction
where 
  contains_explicit_non_none_return(targetFunction) and 
  contains_implicit_return(targetFunction)
select targetFunction,
  "混合使用隐式和显式返回可能表示错误，因为隐式返回总是返回None值。"