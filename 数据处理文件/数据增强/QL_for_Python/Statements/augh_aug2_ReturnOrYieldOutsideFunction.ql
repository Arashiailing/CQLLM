/**
 * @name Incorrect usage of 'return' or 'yield' outside function scope
 * @description Detects 'return', 'yield', or 'yield from' statements that are placed
 *              outside a function definition, which would cause a 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查找在函数外部使用的问题语句
from AstNode problematicStatement, string statementType
where
  (
    // 识别 return 语句
    problematicStatement instanceof Return and statementType = "return"
    or
    // 识别 yield 语句
    problematicStatement instanceof Yield and statementType = "yield"
    or
    // 识别 yield from 语句
    problematicStatement instanceof YieldFrom and statementType = "yield from"
  ) and
  // 确保语句不在函数作用域内
  not problematicStatement.getScope() instanceof Function
// 生成警告信息
select problematicStatement, "Statement '" + statementType + "' is used outside a function definition."