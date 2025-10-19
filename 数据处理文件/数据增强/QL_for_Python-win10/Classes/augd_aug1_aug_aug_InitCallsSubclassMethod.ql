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
 * @id py/init-calls-subclass */

import python

// 定义变量：父类对象、方法标识符、方法调用实例、子类重写方法、父类原始方法、构造函数和self引用
from
  ClassObject baseClass, string methodId, Call methodInvocation, 
  FunctionObject subclassImpl, FunctionObject baseClassMethod, 
  FunctionObject initializer, SelfAttribute selfRef
where
  // 定位基类及其构造函数
  baseClass.declaredAttribute("__init__") = initializer and
  // 确认方法调用发生在构造函数的作用域内
  methodInvocation.getScope() = initializer.getFunction() and
  // 验证调用是通过self引用发起的
  methodInvocation.getFunc() = selfRef and
  // 提取被调用方法的标识符
  selfRef.getName() = methodId and
  // 在基类中查找被调用的方法定义
  baseClassMethod = baseClass.declaredAttribute(methodId) and
  // 确认该方法被子类重写
  subclassImpl.overrides(baseClassMethod)
// 输出警告信息，指出构造函数中的潜在危险调用
select methodInvocation, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseClassMethod, methodId, subclassImpl, subclassImpl.descriptiveString()