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

// 检测父类初始化方法中调用被子类重写的方法
from
  ClassObject superClass, string methodIdentifier, Call methodInvocation,
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // 验证调用发生在父类的__init__方法中
  exists(FunctionObject initializerMethod, SelfAttribute selfAttribute |
    superClass.declaredAttribute("__init__") = initializerMethod and
    methodInvocation.getScope() = initializerMethod.getFunction() and
    methodInvocation.getFunc() = selfAttribute and
    selfAttribute.getName() = methodIdentifier
  ) and
  // 获取父类中声明的方法定义
  overriddenMethod = superClass.declaredAttribute(methodIdentifier) and
  // 确认子类中存在重写该方法的方法
  overridingMethod.overrides(overriddenMethod)
// 输出警告信息，标识问题调用点和相关方法
select methodInvocation, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, methodIdentifier,
  overridingMethod, overridingMethod.descriptiveString()