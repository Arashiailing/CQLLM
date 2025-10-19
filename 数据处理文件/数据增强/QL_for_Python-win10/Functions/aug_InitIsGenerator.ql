/**
 * @name Generator in `__init__` method
 * @description 检测类的初始化方法中是否包含生成器语句（yield 或 yield from）。
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
  // 确保这是一个类的初始化方法
  initMethod.isInitMethod() and
  // 检查方法体中是否存在 yield 语句
  (exists(Yield yieldExpr | yieldExpr.getScope() = initMethod) or
  // 检查方法体中是否存在 yield from 语句
  exists(YieldFrom yieldFromExpr | yieldFromExpr.getScope() = initMethod))
select initMethod, "__init__ method is a generator."