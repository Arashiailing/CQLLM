/**
 * @name `__init__` method returns a value
 * @description In Python, the `__init__` method should only initialize an object instance
 *              and should not explicitly return any value (it implicitly returns None).
 *              Returning a non-None value from `__init__` will raise a TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

// 查找所有位于__init__方法中的Return语句
from Return returnStmt, Expr returnValueExpr
where
  // 确保Return语句位于__init__方法中
  exists(Function initMethod | 
    initMethod.isInitMethod() and 
    returnStmt.getScope() = initMethod
  ) and
  // 获取Return语句的返回值表达式
  returnStmt.getValue() = returnValueExpr and
  // 确保返回值不是None
  not returnValueExpr.pointsTo(Value::none_()) and
  // 排除那些永远不会返回的函数调用
  not exists(FunctionValue funcValue | 
    funcValue.getACall() = returnValueExpr.getAFlowNode() | 
    funcValue.neverReturns()
  ) and
  // 避免重复报告，如果返回结果来自其他__init__函数则不触发
  not exists(Attribute methodAttr | 
    methodAttr = returnValueExpr.(Call).getFunc() | 
    methodAttr.getName() = "__init__"
  )
// 选择Return语句并标记问题
select returnStmt, "Explicit return in __init__ method."