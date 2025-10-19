/**
 * @name `__init__` 方法调用被重写的方法
 * @description 在父类 `__init__` 方法中调用被子类重写的方法可能导致观察到部分初始化的实例。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from ClassObject superClass, string methodName, Call problematicCall, FunctionObject childMethod, FunctionObject parentMethod
where
  // 确保父类存在 `__init__` 方法
  exists(FunctionObject parentInit |
    superClass.declaredAttribute("__init__") = parentInit and
    // 方法调用发生在父类的 `__init__` 方法作用域内
    problematicCall.getScope() = parentInit.getFunction()
  |
    // 方法调用通过 self 属性进行
    exists(SelfAttribute selfAttr |
      problematicCall.getFunc() = selfAttr and
      // 获取被调用方法的名称
      selfAttr.getName() = methodName and
      // 确认该方法在父类中声明
      parentMethod = superClass.declaredAttribute(methodName) and
      // 验证该方法被子类重写
      childMethod.overrides(parentMethod)
    )
  )
select problematicCall, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName, childMethod, childMethod.descriptiveString()