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

// 导入Python库和表达式调用参数模块
import python
import Expressions.CallArgs

// 从调用、类值、字符串名称和函数值中进行查询
from Call call, ClassValue cls, string name, FunctionValue init
where
  // 检查是否存在非法命名的参数，并获取类的初始化方法
  illegally_named_parameter(call, cls, name) and
  init = get_function_or_initializer(cls)
select call, "Keyword argument '" + name + "' is not a supported parameter name of $@.", init,
  // 选择调用、错误信息、初始化方法和其限定名
  init.getQualifiedName()
