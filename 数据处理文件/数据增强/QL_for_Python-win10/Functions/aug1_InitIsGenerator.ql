/**
 * @name `__init__` method is a generator
 * @description 检测作为生成器的`__init__`方法。在Python中，`__init__`方法通常不应该作为生成器，因为它用于初始化对象实例。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initMethod
where
  // 确认函数是类的初始化方法（即 __init__ 方法）
  initMethod.isInitMethod() and
  // 检查函数体内是否存在 yield 或 yield from 语句，这些语句表明函数是生成器
  (
    exists(Yield yieldNode | yieldNode.getScope() = initMethod) or
    exists(YieldFrom yieldFromNode | yieldFromNode.getScope() = initMethod)
  )
select initMethod, "__init__ method is a generator."