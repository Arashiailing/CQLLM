/**
 * @name `__init__` method calls overridden method
 * @description Detects when an `__init__` method calls a method that is overridden by a subclass.
 *              This can lead to a partially initialized instance being observed by the subclass method.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// 查找在父类的 __init__ 方法中调用的、被子类重写的方法
from
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject subclassMethod, FunctionObject parentMethod
where
  // 确保存在一个 __init__ 方法，并且在其中有一个通过 self 调用的方法
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // 获取父类的 __init__ 方法
    parentClass.declaredAttribute("__init__") = initMethod and
    // 确认调用发生在 __init__ 方法的作用域内
    methodCall.getScope() = initMethod.getFunction() and
    // 确认调用的是 self 的属性
    methodCall.getFunc() = selfAttr
  |
    // 确认被调用的 self 属性名称与我们要检查的方法名相同
    selfAttr.getName() = methodName and
    // 获取父类中声明的方法
    parentMethod = parentClass.declaredAttribute(methodName) and
    // 确认存在一个子类方法重写了父类方法
    subclassMethod.overrides(parentMethod)
  )
// 选择符合条件的调用，并生成警告信息
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName,
  subclassMethod, subclassMethod.descriptiveString()