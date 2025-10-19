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

// 查找父类__init__方法中调用被子类重写的方法
from
  ClassObject parentClass, string methodName, Call problematicCall,
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // 确保调用发生在父类的__init__方法中，且调用的是self的属性
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    parentClass.declaredAttribute("__init__") = initMethod and
    problematicCall.getScope() = initMethod.getFunction() and
    problematicCall.getFunc() = selfAttr and
    selfAttr.getName() = methodName
  ) and
  // 获取父类中声明的方法（被重写的方法）
  overriddenMethod = parentClass.declaredAttribute(methodName) and
  // 确认子类中存在重写该方法的方法
  overridingMethod.overrides(overriddenMethod)
// 输出问题调用及关联方法信息
select problematicCall, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, methodName,
  overridingMethod, overridingMethod.descriptiveString()