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

from ClassObject parentClass, string methodName, Call methodCall, FunctionObject subclassMethod, FunctionObject parentMethod
where
  // 检查是否存在一个名为`__init__`的方法，并且该方法在当前作用域内被调用
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // 获取父类的`__init__`方法
    parentClass.declaredAttribute("__init__") = initMethod and
    // 确认调用的作用域是`__init__`方法
    methodCall.getScope() = initMethod.getFunction() and
    // 确认调用的是self属性
    methodCall.getFunc() = selfAttr
  |
    // 确认self属性的名称与methodName相同
    selfAttr.getName() = methodName and
    // 获取父类中声明的methodName方法
    parentMethod = parentClass.declaredAttribute(methodName) and
    // 确认子类中的subclassMethod方法重写了父类的parentMethod方法
    subclassMethod.overrides(parentMethod)
  )
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName, subclassMethod, subclassMethod.descriptiveString()