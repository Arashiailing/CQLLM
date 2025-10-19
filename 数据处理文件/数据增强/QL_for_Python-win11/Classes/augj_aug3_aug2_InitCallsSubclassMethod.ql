/**
 * @name `__init__` 方法调用被重写的方法
 * @description 在 `__init__` 方法中调用被子类重写的方法可能导致观察到部分初始化的实例。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from ClassObject superClass, string methodName, Call methodCall, FunctionObject subclassMethod, FunctionObject superclassMethod
where
  // 检查父类中存在`__init__`方法，并且方法调用发生在该`__init__`方法内
  exists(FunctionObject initMethod |
    superClass.declaredAttribute("__init__") = initMethod and
    methodCall.getScope() = initMethod.getFunction()
  ) and
  // 检查方法调用是通过self属性进行的，并且该方法被子类重写
  exists(SelfAttribute selfAttr |
    methodCall.getFunc() = selfAttr and
    selfAttr.getName() = methodName and
    superclassMethod = superClass.declaredAttribute(methodName) and
    subclassMethod.overrides(superclassMethod)
  )
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", superclassMethod, methodName, subclassMethod, subclassMethod.descriptiveString()