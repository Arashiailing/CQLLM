/**
 * @name 错误的类实例化参数数量
 * @description 检测类构造函数调用时参数数量不匹配的问题。
 *              当调用类的 `__init__` 方法时，传递过多或过少的参数
 *              将在运行时引发 TypeError 异常。
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

from Call classCall, ClassValue instantiatedClass, string problemType, string limitType, int expectedArgCount, FunctionValue classInitializer
where
  // 确定参数数量问题的类型（过多或过少）
  (
    // 检测参数过多的情况
    too_many_args(classCall, instantiatedClass, expectedArgCount) and
    problemType = "too many arguments" and
    limitType = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(classCall, instantiatedClass, expectedArgCount) and
    problemType = "too few arguments" and
    limitType = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  classInitializer = get_function_or_initializer(instantiatedClass)
select classCall, 
  "Call to $@ with " + problemType + "; should be " + limitType + expectedArgCount.toString() + ".", 
  classInitializer,
  classInitializer.getQualifiedName()