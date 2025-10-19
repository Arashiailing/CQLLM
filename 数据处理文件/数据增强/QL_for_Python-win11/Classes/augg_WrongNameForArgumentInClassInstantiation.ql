/**
 * @name Wrong name for an argument in a class instantiation
 * @description Using a named argument whose name does not correspond to a
 *              parameter of the __init__ method of the class being
 *              instantiated, will result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// 导入Python核心库和表达式调用参数分析模块
import python
import Expressions.CallArgs

// 从类实例化调用、目标类对象、错误参数名和初始化方法中查询
from Call instanceCall, ClassValue targetClass, string erroneousParam, FunctionValue initializerMethod
where
  // 确保调用中存在非法命名的参数
  illegally_named_parameter(instanceCall, targetClass, erroneousParam) and
  // 获取目标类的初始化函数(__init__)
  initializerMethod = get_function_or_initializer(targetClass)
select instanceCall, "Keyword argument '" + erroneousParam + "' is not a supported parameter name of $@.", initializerMethod,
  // 输出实例化调用、错误信息、初始化方法及其完全限定名
  initializerMethod.getQualifiedName()