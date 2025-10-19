/**
 * @name Ratio of jump-to-definitions computed
 * @description This query calculates the percentage of expressions that can jump to definitions
 * 计算能够跳转到定义的表达式所占的比例
 */

import python
import analysis.DefinitionTracking

/**
 * Determines if an expression is expected to have a definition
 * 判断表达式是否期望有定义
 * 
 * An expression expects a definition if:
 * 表达式期望有定义的条件：
 * 1. It is not a built-in object (like len, tuple, etc.)
 *    不是内建对象（如len, tuple等）
 * 2. It falls into one of these categories:
 *    是以下类型之一：
 *    - A name with load context
 *      名称且上下文是加载操作
 *    - An attribute with load context
 *      属性且上下文是加载操作
 *    - An import member
 *      导入成员
 *    - An import expression
 *      导入表达式
 */
predicate shouldHaveDefinition(Expr expression) {
  // Ensure the expression doesn't point to a built-in value
  // 确保表达式不指向内建值
  not exists(Value builtinValue | 
    expression.pointsTo(builtinValue) and builtinValue.isBuiltin()) and
  (
    // Check for name with load context
    // 检查名称且上下文是加载操作
    expression instanceof Name and expression.(Name).getCtx() instanceof Load
    or
    // Check for attribute with load context
    // 检查属性且上下文是加载操作
    expression instanceof Attribute and expression.(Attribute).getCtx() instanceof Load
    or
    // Check for import member
    // 检查导入成员
    expression instanceof ImportMember
    or
    // Check for import expression
    // 检查导入表达式
    expression instanceof ImportExpr
  )
}

from int hasUniqueDefinitionCount, int noUniqueDefinitionCount
where
  // Calculate the count of expressions with unique definitions
  // 计算有唯一定义的表达式数量
  hasUniqueDefinitionCount = count(Expr expression | 
    shouldHaveDefinition(expression) and exists(getUniqueDefinition(expression))) and
  // Calculate the count of expressions without unique definitions
  // 计算没有唯一定义的表达式数量
  noUniqueDefinitionCount = count(Expr expression | 
    shouldHaveDefinition(expression) and not exists(getUniqueDefinition(expression)))
select hasUniqueDefinitionCount, noUniqueDefinitionCount, 
  hasUniqueDefinitionCount * 100 / (hasUniqueDefinitionCount + noUniqueDefinitionCount) + "%"