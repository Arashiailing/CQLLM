/**
 * @name Constructor calls overridable method
 * @description Detects when a class's `__init__` method invokes another method that can be overridden 
 *              by subclasses, which may lead to observing a partially initialized object.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass */

import python

// 查找父类构造函数中调用可被子类重写方法的情况
from
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject overridingMethod, FunctionObject overriddenMethod, 
  FunctionObject constructorMethod, SelfAttribute selfAttribute
where
  // 确定父类及其构造函数
  parentClass.declaredAttribute("__init__") = constructorMethod and
  // 验证方法调用发生在构造函数作用域内
  methodCall.getScope() = constructorMethod.getFunction() and
  // 确认调用通过self属性发起
  methodCall.getFunc() = selfAttribute and
  // 获取被调用方法的名称
  selfAttribute.getName() = methodName and
  // 在父类中定位被调用的方法
  overriddenMethod = parentClass.declaredAttribute(methodName) and
  // 确认存在子类重写了该方法
  overridingMethod.overrides(overriddenMethod)
// 输出警告信息，指示构造函数中的危险调用
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  overriddenMethod, methodName, overridingMethod, overridingMethod.descriptiveString()