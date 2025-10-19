/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Mixing implicit and explicit returns indicates a likely error as implicit returns always return 'None'.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// 定义一个谓词函数，用于判断函数是否显式返回非None值
predicate explicitly_returns_non_none(Function func) {
  // 检查是否存在一个返回语句，其作用域为当前函数，并且返回的值不是None
  exists(Return return |
    return.getScope() = func and
    exists(Expr val | val = return.getValue() | not val instanceof None)
  )
}

// 定义一个谓词函数，用于判断函数是否有隐式返回
predicate has_implicit_return(Function func) {
  // 检查是否存在一个控制流节点，该节点是当前函数的fallthrough节点且不太可能被到达
  exists(ControlFlowNode fallthru |
    fallthru = func.getFallthroughNode() and not fallthru.unlikelyReachable()
  )
  // 或者检查是否存在一个返回语句，其作用域为当前函数但没有返回值
  or
  exists(Return return | return.getScope() = func and not exists(return.getValue()))
}

// 从所有函数中选择那些同时具有显式返回非None值和隐式返回的函数
from Function func
where explicitly_returns_non_none(func) and has_implicit_return(func)
select func,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."
