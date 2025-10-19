/**
 * @name Constructor calls overridable method
 * @description Identifies potential issues where a class constructor invokes methods 
 *              that can be overridden by subclasses, potentially exposing partially 
 *              initialized objects to subclass implementations.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass */

import python

// 检测构造函数中调用可被子类重写方法的安全隐患
from
  ClassObject baseClass, string calledMethodName, Call initMethodCall, 
  FunctionObject subclassMethod, FunctionObject baseMethod, 
  FunctionObject initMethod, SelfAttribute selfMethodAccess
where
  // 验证基类构造函数的存在性
  baseClass.declaredAttribute("__init__") = initMethod and
  // 确认方法调用发生在构造函数的上下文中
  initMethodCall.getScope() = initMethod.getFunction() and
  // 验证方法调用是通过self引用发起的
  initMethodCall.getFunc() = selfMethodAccess and
  // 获取被调用方法的标识符
  selfMethodAccess.getName() = calledMethodName and
  // 在基类中定位被调用的方法定义
  baseMethod = baseClass.declaredAttribute(calledMethodName) and
  // 检查是否存在子类对该方法进行了重写
  subclassMethod.overrides(baseMethod)
// 生成告警信息，指出构造函数中的潜在危险调用
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseMethod, calledMethodName, subclassMethod, subclassMethod.descriptiveString()