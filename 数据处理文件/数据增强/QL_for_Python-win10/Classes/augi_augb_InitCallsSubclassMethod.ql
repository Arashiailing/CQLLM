/**
 * @name `__init__` method calls overridden method
 * @description Calling a method from `__init__` that is overridden by a subclass may result in a partially
 *              initialized instance being observed.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// 查找基类__init__方法中调用被子类重写方法的情况
from
  ClassObject baseClass, string calledMethodName, Call initMethodCall, 
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // 条件1: 确保调用发生在基类的__init__方法中，且通过self属性访问
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    baseClass.declaredAttribute("__init__") = initMethod and
    initMethodCall.getScope() = initMethod.getFunction() and
    initMethodCall.getFunc() = selfAttr and
    selfAttr.getName() = calledMethodName
  ) and
  // 条件2: 获取基类中声明的方法定义
  overriddenMethod = baseClass.declaredAttribute(calledMethodName) and
  // 条件3: 确认子类方法重写了基类方法
  overridingMethod.overrides(overriddenMethod)
// 输出调用位置及警告信息
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, calledMethodName,
  overridingMethod, overridingMethod.descriptiveString()