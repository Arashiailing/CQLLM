/**
 * @name 类构造函数参数数量不匹配
 * @description 当实例化类时，如果提供给 `__init__` 方法的参数数量与定义不符，
 *              会引发运行时 TypeError 异常。本查询检测两种情况：
 *              1. 传递参数超过构造函数定义数量
 *              2. 传递参数少于构造函数定义数量
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

from Call classCall, ClassValue targetClass, string argIssueType, string constraintDesc, int expectedCount, FunctionValue classInitMethod
where
  // 获取目标类的构造函数或初始化方法
  classInitMethod = get_function_or_initializer(targetClass) and
  (
    // 检测参数过多的情况
    too_many_args(classCall, targetClass, expectedCount) and
    argIssueType = "too many arguments" and
    constraintDesc = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(classCall, targetClass, expectedCount) and
    argIssueType = "too few arguments" and
    constraintDesc = "no fewer than "
  )
select classCall, "Call to $@ with " + argIssueType + "; should be " + constraintDesc + expectedCount.toString() + ".", classInitMethod,
  classInitMethod.getQualifiedName()