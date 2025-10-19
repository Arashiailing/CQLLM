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

// 查找在父类的 __init__ 方法中调用被子类重写的方法的情况
from
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // 确保存在一个父类的 __init__ 方法
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // 获取父类的 __init__ 方法
    parentClass.declaredAttribute("__init__") = initMethod and
    // 确认方法调用发生在 __init__ 方法的作用域内
    methodCall.getScope() = initMethod.getFunction() and
    // 确认调用的是 self 属性
    methodCall.getFunc() = selfAttr
  |
    // 确认 self 属性的名称与目标方法名相同
    selfAttr.getName() = methodName and
    // 获取父类中声明的目标方法
    overriddenMethod = parentClass.declaredAttribute(methodName) and
    // 确认存在一个子类重写了父类的方法
    overridingMethod.overrides(overriddenMethod)
  )
// 输出警告信息，指示在 __init__ 方法中调用了被子类重写的方法
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  overriddenMethod, methodName, overridingMethod, overridingMethod.descriptiveString()