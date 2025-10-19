/**
 * @name 错误的类实例化参数数量
 * @description 识别类实例化调用中参数数量与构造函数（__init__方法）定义不匹配的情况。
 *              此类问题会在运行时引发TypeError异常，降低程序稳定性。
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

from Call classCreationCall, ClassValue targetClass, string argErrorType, string argConstraintPrefix, int requiredArgCount, FunctionValue classInitializer
where
  // 获取目标类的构造函数（通常是__init__方法）
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量超过上限的情况
    too_many_args(classCreationCall, targetClass, requiredArgCount) and
    argErrorType = "too many arguments" and
    argConstraintPrefix = "no more than "
  )
  or
  (
    // 处理参数数量低于下限的情况
    too_few_args(classCreationCall, targetClass, requiredArgCount) and
    argErrorType = "too few arguments" and
    argConstraintPrefix = "no fewer than "
  )
select classCreationCall, "Call to $@ with " + argErrorType + "; should be " + argConstraintPrefix + requiredArgCount.toString() + ".", classInitializer,
  // 输出调用点、错误消息及构造函数的完全限定名
  classInitializer.getQualifiedName()