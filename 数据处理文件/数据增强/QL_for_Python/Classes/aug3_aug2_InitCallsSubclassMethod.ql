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

from ClassObject parentCls, string methodIdentifier, Call overriddenMethodCall, FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // 确保父类具有`__init__`方法
  exists(FunctionObject initializer |
    parentCls.declaredAttribute("__init__") = initializer and
    // 方法调用发生在父类的`__init__`方法内
    overriddenMethodCall.getScope() = initializer.getFunction()
  |
    // 方法调用是通过self属性进行的
    exists(SelfAttribute selfAttribute |
      overriddenMethodCall.getFunc() = selfAttribute and
      // 获取被调用方法的名称
      selfAttribute.getName() = methodIdentifier and
      // 确认该方法是父类中声明的方法
      overriddenMethod = parentCls.declaredAttribute(methodIdentifier) and
      // 验证该方法被子类重写
      overridingMethod.overrides(overriddenMethod)
    )
  )
select overriddenMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, methodIdentifier, overridingMethod, overridingMethod.descriptiveString()