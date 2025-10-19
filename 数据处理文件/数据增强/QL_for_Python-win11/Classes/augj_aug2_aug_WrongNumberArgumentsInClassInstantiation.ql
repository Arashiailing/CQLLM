/**
 * @name 类实例化参数数量不匹配
 * @description 检测类实例化时传入构造函数的参数数量错误，
 *              参数过多或过少均会导致运行时 TypeError 异常
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

from Call callExpr, ClassValue cls, 
     string errorType, string constraintPrefix, 
     int requiredCount, FunctionValue constructor
where
  // 获取目标类的构造函数（__init__方法）
  constructor = get_function_or_initializer(cls) and
  (
    // 检测参数数量过多的场景
    too_many_args(callExpr, cls, requiredCount) and
    errorType = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 检测参数数量不足的场景
    too_few_args(callExpr, cls, requiredCount) and
    errorType = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select callExpr, 
       "Call to $@ with " + errorType + "; should be " + constraintPrefix + requiredCount.toString() + ".", 
       constructor,
       // 输出调用点、错误消息及构造函数的完全限定名
       constructor.getQualifiedName()