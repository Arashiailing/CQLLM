/**
 * @name `__init__` method is a generator
 * @description `__init__` 方法是一个生成器。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function func
where
  // 验证函数是否为类的初始化方法（__init__）
  func.isInitMethod() and
  (
    // 确认函数体中包含 yield 表达式，表明该函数为生成器函数
    exists(Yield yieldExpr | yieldExpr.getScope() = func) or
    // 确认函数体中包含 yield from 表达式，表明该函数为生成器函数
    exists(YieldFrom yieldFromExpr | yieldFromExpr.getScope() = func)
  )
select func, "__init__ method is a generator."