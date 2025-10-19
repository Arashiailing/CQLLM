/**
 * @name `__init__` 方法调用被重写的方法
 * @description 在父类初始化方法中调用被子类重写的方法可能导致实例处于部分初始化状态。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from ClassObject superClass, string methodName, Call methodCall, FunctionObject subMethod, FunctionObject superMethod
where
  // 确保父类存在初始化方法
  exists(FunctionObject initMethod |
    superClass.declaredAttribute("__init__") = initMethod and
    // 方法调用发生在初始化方法作用域内
    methodCall.getScope() = initMethod.getFunction()
  |
    // 方法调用通过self属性触发
    exists(SelfAttribute selfAttr |
      methodCall.getFunc() = selfAttr and
      // 获取被调用方法的标识符
      selfAttr.getName() = methodName and
      // 确认方法在父类中声明
      superMethod = superClass.declaredAttribute(methodName) and
      // 验证方法被子类重写
      subMethod.overrides(superMethod)
    )
  )
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", superMethod, methodName, subMethod, subMethod.descriptiveString()