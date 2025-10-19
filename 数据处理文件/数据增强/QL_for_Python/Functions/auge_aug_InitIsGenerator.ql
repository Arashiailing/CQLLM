/**
 * @name Generator in `__init__` method
 * @description 识别并报告在类的初始化方法中使用生成器语句（yield 或 yield from）的情况。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initializerMethod
where
  // 验证该函数是类的初始化方法
  initializerMethod.isInitMethod() and
  // 检查方法体中是否包含任何形式的生成器语句
  exists(Expr generatorExpr | 
    generatorExpr.getScope() = initializerMethod and
    (generatorExpr instanceof Yield or generatorExpr instanceof YieldFrom))
select initializerMethod, "__init__ method is a generator."