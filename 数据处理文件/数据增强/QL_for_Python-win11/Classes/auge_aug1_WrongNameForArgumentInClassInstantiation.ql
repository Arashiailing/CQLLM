/**
 * @name 类实例化中的错误参数名
 * @description 检测类实例化时使用了关键字参数，但该参数名在类的__init__方法中不存在。
 *              这种不匹配会导致运行时TypeError。
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

import python
import Expressions.CallArgs

from Call classCall, ClassValue targetClass, string invalidKeyword, FunctionValue initMethod
where
  // 识别类实例化中的非法关键字参数
  illegally_named_parameter(classCall, targetClass, invalidKeyword) and
  // 获取目标类的初始化方法
  initMethod = get_function_or_initializer(targetClass)
select classCall, 
       "关键字参数 '" + invalidKeyword + "' 不是 $@ 支持的参数名。", 
       initMethod,
       initMethod.getQualifiedName()