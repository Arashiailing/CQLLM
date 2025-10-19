/**
 * @name 错误的类实例化参数数量
 * @description 通过分析类实例化调用与构造函数参数定义，检测参数数量不匹配的情况。
 *              当实例化类时传入的参数数量与构造函数（__init__方法）定义不符，
 *              程序将在运行时抛出TypeError异常，影响程序的可靠性和正确性。
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

from Call classCreationCall, ClassValue targetClass, string errorMessage, string constraintText, int requiredArgCount, FunctionValue classInitializer
where
  // 获取目标类的构造函数（通常是__init__方法）
  classInitializer = get_function_or_initializer(targetClass)
  and
  (
    // 检查参数数量超过上限的情况
    too_many_args(classCreationCall, targetClass, requiredArgCount)
    and errorMessage = "too many arguments"
    and constraintText = "no more than "
    or
    // 检查参数数量低于下限的情况
    too_few_args(classCreationCall, targetClass, requiredArgCount)
    and errorMessage = "too few arguments"
    and constraintText = "no fewer than "
  )
select classCreationCall, 
  "Call to $@ with " + errorMessage + "; should be " + constraintText + requiredArgCount.toString() + ".", 
  classInitializer,
  // 输出构造函数的完全限定名，以便定位问题
  classInitializer.getQualifiedName()