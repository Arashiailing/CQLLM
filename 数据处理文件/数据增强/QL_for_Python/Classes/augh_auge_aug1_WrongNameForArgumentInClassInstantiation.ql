/**
 * @name 类实例化中的错误参数名
 * @description 检测类实例化时使用了关键字参数，但该参数名在类的__init__方法中不存在。
 *              这种参数不匹配会导致运行时TypeError异常。
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

from Call instanceCall, ClassValue targetClass, string wrongArgName, FunctionValue initializer
where
  // 识别类实例化调用中的非法关键字参数
  illegally_named_parameter(instanceCall, targetClass, wrongArgName) and
  // 获取目标类的初始化方法
  initializer = get_function_or_initializer(targetClass)
select instanceCall, 
       "关键字参数 '" + wrongArgName + "' 不是 $@ 支持的参数名。", 
       initializer,
       initializer.getQualifiedName()