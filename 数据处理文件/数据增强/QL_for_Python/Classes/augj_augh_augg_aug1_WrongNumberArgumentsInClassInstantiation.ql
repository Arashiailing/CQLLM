/**
 * @name 类实例化参数数量不匹配
 * @description 检测在创建类实例时，传递给构造函数的参数数量与定义不符的情况。
 *              当调用类的初始化方法 `__init__` 时，若提供的实参数量不正确，
 *              程序将在运行时抛出 TypeError 异常。
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

from Call instanceCreation, ClassValue instantiatedClass, string errorDescription, string parameterConstraint, int expectedArgumentCount, FunctionValue classInitializer
where
  (
    // 处理参数数量超出预期的场景
    exists(int expectedCount |
      too_many_args(instanceCreation, instantiatedClass, expectedCount) and
      expectedArgumentCount = expectedCount and
      errorDescription = "too many arguments" and
      parameterConstraint = "no more than "
    )
    or
    // 处理参数数量不足的场景
    exists(int expectedCount |
      too_few_args(instanceCreation, instantiatedClass, expectedCount) and
      expectedArgumentCount = expectedCount and
      errorDescription = "too few arguments" and
      parameterConstraint = "no fewer than "
    )
  ) and
  // 获取目标类的初始化方法
  classInitializer = get_function_or_initializer(instantiatedClass)
select instanceCreation, 
  "Call to $@ with " + errorDescription + "; should be " + parameterConstraint + expectedArgumentCount.toString() + ".", 
  classInitializer,
  classInitializer.getQualifiedName()