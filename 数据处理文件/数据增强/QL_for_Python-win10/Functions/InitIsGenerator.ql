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

from Function f
where
  // 检查函数是否是类的初始化方法（即 __init__ 方法）
  f.isInitMethod() and
  // 检查函数体内是否存在 yield 或 yield from 语句，表示该函数是生成器
  (exists(Yield y | y.getScope() = f) or exists(YieldFrom y | y.getScope() = f))
select f, "__init__ method is a generator."
