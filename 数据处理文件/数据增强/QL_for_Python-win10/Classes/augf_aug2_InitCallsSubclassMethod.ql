/**
 * @name `__init__` 方法调用被子类重写的方法
 * @description 在类的初始化方法中调用被子类覆盖的方法可能导致对象处于部分初始化状态。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from ClassObject superClass, string methodIdentifier, Call invocation, FunctionObject overriddenMethod, FunctionObject baseMethod
where
  exists(FunctionObject initializerMethod, SelfAttribute selfReference |
    superClass.declaredAttribute("__init__") = initializerMethod and
    invocation.getScope() = initializerMethod.getFunction() and
    invocation.getFunc() = selfReference
  |
    selfReference.getName() = methodIdentifier and
    baseMethod = superClass.declaredAttribute(methodIdentifier) and
    overriddenMethod.overrides(baseMethod)
  )
select invocation, "Call to self.$@ in __init__ method, which is overridden by $@.", baseMethod, methodIdentifier, overriddenMethod, overriddenMethod.descriptiveString()