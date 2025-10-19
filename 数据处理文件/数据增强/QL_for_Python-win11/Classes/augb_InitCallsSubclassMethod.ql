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

// 查找在父类的__init__方法中调用被子类重写的方法的情况
from
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject subclassMethod, FunctionObject parentMethod
where
  // 步骤1-3: 确保存在父类的__init__方法，方法调用发生在其中，并且调用的是self的属性
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    parentClass.declaredAttribute("__init__") = initMethod and
    methodCall.getScope() = initMethod.getFunction() and
    methodCall.getFunc() = selfAttr and
    selfAttr.getName() = methodName
  ) and
  // 步骤4: 获取父类中声明的方法
  parentMethod = parentClass.declaredAttribute(methodName) and
  // 步骤5: 确认子类中的方法重写了父类的方法
  subclassMethod.overrides(parentMethod)
// 选择符合条件的调用，并生成警告信息
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName,
  subclassMethod, subclassMethod.descriptiveString()