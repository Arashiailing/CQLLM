/**
 * @name `__init__` method is a generator
 * @description 标识出作为生成器的 `__init__` 方法。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initFunc
where
  // 确保函数是类的初始化方法
  initFunc.isInitMethod() and
  // 检查函数是否包含生成器特性（yield 或 yield from）
  (
    exists(Yield yieldStmt | yieldStmt.getScope() = initFunc) or
    exists(YieldFrom yieldStmt | yieldStmt.getScope() = initFunc)
  )
select initFunc, "__init__ method is a generator."