/**
 * @name Constructor calls overridable method
 * @description Detects when a class's `__init__` method invokes another method that can be overridden 
 *              by subclasses, which may lead to observing a partially initialized object.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// 查找在父类的构造函数中调用被子类重写的方法的情况
from
  ClassObject superClass, string targetMethodName, Call invocation, 
  FunctionObject subclassMethod, FunctionObject superclassMethod, 
  FunctionObject initMethod, SelfAttribute selfAttr
where
  // 获取父类的构造函数
  superClass.declaredAttribute("__init__") = initMethod and
  // 确认方法调用发生在构造函数的作用域内
  invocation.getScope() = initMethod.getFunction() and
  // 确认调用的是 self 属性
  invocation.getFunc() = selfAttr and
  // 确认 self 属性的名称与目标方法名相同
  selfAttr.getName() = targetMethodName and
  // 获取父类中声明的目标方法
  superclassMethod = superClass.declaredAttribute(targetMethodName) and
  // 确认存在一个子类重写了父类的方法
  subclassMethod.overrides(superclassMethod)
// 输出警告信息，指示在构造函数中调用了被子类重写的方法
select invocation, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superclassMethod, targetMethodName, subclassMethod, subclassMethod.descriptiveString()