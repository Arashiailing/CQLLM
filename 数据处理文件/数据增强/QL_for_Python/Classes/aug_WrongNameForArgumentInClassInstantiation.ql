/**
 * @name Wrong name for an argument in a class instantiation
 * @description Using a named argument whose name does not correspond to a
 *              parameter of the __init__ method of the class being
 *              instantiated, will result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// 导入 Python 分析库和调用参数相关模块
import python
import Expressions.CallArgs

// 查找类实例化调用中使用了无效命名参数的情况
from Call classInstantiation, ClassValue targetClass, string invalidArgName, FunctionValue initializerMethod
where
  // 确认调用中存在非法命名的参数
  illegally_named_parameter(classInstantiation, targetClass, invalidArgName) and
  // 获取目标类的初始化方法
  initializerMethod = get_function_or_initializer(targetClass)
select 
  // 报告位置：类实例化调用
  classInstantiation, 
  // 错误信息：指出哪个参数名称不被支持
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  // 相关元素：初始化方法
  initializerMethod,
  // 初始化方法的限定名
  initializerMethod.getQualifiedName()