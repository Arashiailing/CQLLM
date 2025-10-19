/**
 * @name 类实例化参数数量错误
 * @description 检测在创建类实例时传递的参数数量与类构造函数(__init__)定义不符的情况，
 *              这种参数不匹配会在程序执行时导致TypeError异常。
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-number-class-arguments
 */

import python
import Expressions.CallArgs

from Call classCreation, ClassValue targetClass, string errorKind, string constraintPrefix, int requiredArgCount, FunctionValue classConstructor
where
  // 获取目标类的构造函数
  classConstructor = get_function_or_initializer(targetClass)
  and (
    // 检查参数数量超过定义的情况
    too_many_args(classCreation, targetClass, requiredArgCount)
    and errorKind = "too many arguments"
    and constraintPrefix = "no more than "
    or
    // 检查参数数量不足的情况
    too_few_args(classCreation, targetClass, requiredArgCount)
    and errorKind = "too few arguments"
    and constraintPrefix = "no fewer than "
  )
select classCreation, 
  "Call to $@ with " + errorKind + "; should be " + constraintPrefix + requiredArgCount.toString() + ".", 
  classConstructor,
  // 输出类实例化位置、错误详情以及构造函数的完整限定名
  classConstructor.getQualifiedName()