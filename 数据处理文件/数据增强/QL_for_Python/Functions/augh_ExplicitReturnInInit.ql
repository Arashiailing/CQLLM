/**
 * @name `__init__` method returns a value
 * @description Detects explicit non-None return values in `__init__` methods, which cause TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

// 查找所有在__init__方法中的返回语句
from Return returnStmt, Expr returnedValue
where
  // 确认返回语句位于__init__方法的作用域内
  exists(Function initMethod | 
    initMethod.isInitMethod() and 
    returnStmt.getScope() = initMethod
  ) and
  // 将返回值与表达式关联
  returnStmt.getValue() = returnedValue and
  // 排除返回None的情况（这是合法的）
  not returnedValue.pointsTo(Value::none_()) and
  // 排除永不返回的函数调用情况
  not exists(FunctionValue funcValue | 
    funcValue.getACall() = returnedValue.getAFlowNode() | 
    funcValue.neverReturns()
  ) and
  // 避免误报：排除返回其他__init__方法调用的情况
  not exists(Attribute methodAttr | 
    methodAttr = returnedValue.(Call).getFunc() | 
    methodAttr.getName() = "__init__"
  )
// 选择违规的返回语句并显示问题描述
select returnStmt, "Explicit return in __init__ method."