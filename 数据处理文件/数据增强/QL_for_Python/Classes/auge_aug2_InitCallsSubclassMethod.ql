/**
 * @name `__init__` 方法调用被重写的方法
 * @description 在父类构造函数中调用被子类重写的方法可能导致观察到部分初始化的实例。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from ClassObject superClass, string overriddenMethodName, Call initCall, FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // 确保存在父类的__init__方法且调用发生在其中
  exists(FunctionObject initMethod |
    superClass.declaredAttribute("__init__") = initMethod and
    initCall.getScope() = initMethod.getFunction()
  ) and
  // 确认调用通过self属性进行并获取方法名
  exists(SelfAttribute selfAttr |
    initCall.getFunc() = selfAttr and
    selfAttr.getName() = overriddenMethodName
  ) and
  // 获取父类声明的目标方法
  overriddenMethod = superClass.declaredAttribute(overriddenMethodName) and
  // 验证存在子类方法重写父类方法
  overridingMethod.overrides(overriddenMethod)
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, overriddenMethodName, overridingMethod, overridingMethod.descriptiveString()