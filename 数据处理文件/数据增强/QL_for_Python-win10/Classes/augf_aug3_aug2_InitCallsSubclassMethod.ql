/**
 * @name `__init__` 方法调用被重写的方法
 * @description 在父类 `__init__` 方法中通过 self 调用被子类重写的方法可能导致部分初始化的实例被访问。
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
  // 父类必须定义 `__init__` 方法
  exists(FunctionObject initializer |
    superClass.declaredAttribute("__init__") = initializer and
    // 方法调用发生在父类的 `__init__` 方法作用域内
    methodCall.getScope() = initializer.getFunction()
  |
    // 调用必须通过 self 属性进行
    exists(SelfAttribute selfAttr |
      methodCall.getFunc() = selfAttr and
      // 获取被调用方法的名称
      selfAttr.getName() = methodName and
      // 确认该方法在父类中声明
      superMethod = superClass.declaredAttribute(methodName) and
      // 验证该方法被子类重写
      subMethod.overrides(superMethod)
    )
  )
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", superMethod, methodName, subMethod, subMethod.descriptiveString()