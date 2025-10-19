/**
 * @name `__init__` method returns a value
 * @description Explicitly returning a value from an `__init__` method will raise a TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python  // 导入Python库，用于分析Python代码

// 从Return和Expr类中选择数据
from Return r, Expr rv
where
  // 存在一个初始化方法（__init__），并且返回值的作用域在该初始化方法内
  exists(Function init | init.isInitMethod() and r.getScope() = init) and
  // 返回值等于表达式rv
  r.getValue() = rv and
  // rv不指向None值
  not rv.pointsTo(Value::none_()) and
  // 不存在一个函数调用，该调用永不返回
  not exists(FunctionValue f | f.getACall() = rv.getAFlowNode() | f.neverReturns()) and
  // 避免重复报告，如果返回结果来自其他__init__函数则不触发
  not exists(Attribute meth | meth = rv.(Call).getFunc() | meth.getName() = "__init__")
// 选择返回值r，并标记为“在__init__方法中显式返回”
select r, "Explicit return in __init__ method."
