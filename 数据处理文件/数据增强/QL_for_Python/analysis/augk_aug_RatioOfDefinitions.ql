/**
 * @name Ratio of jump-to-definitions computed
 * @description 计算能够跳转到定义的表达式所占的比例
 * Ratio of expressions that can jump to definitions
 */

import python
import analysis.DefinitionTracking

/**
 * 判断表达式是否期望有定义
 * Determine whether an expression expects to have a definition
 * 表达式期望有定义的条件：
 * 1. 不是内建对象（如len, tuple等）
 *    Not a built-in object (like len, tuple, etc.)
 * 2. 是以下类型之一：
 *    Is one of the following types:
 *    - 名称且上下文是加载操作
 *      Name with load context
 *    - 属性且上下文是加载操作
 *      Attribute with load context
 *    - 导入成员
 *      Import member
 *    - 导入表达式
 *      Import expression
 */
predicate expressionExpectsDefinition(Expr expression) {
  /* 排除内建对象 */
  /* Exclude built-in objects */
  not exists(Value builtinValue | 
    expression.pointsTo(builtinValue) and builtinValue.isBuiltin()) and
  (
    expression instanceof Name and expression.(Name).getCtx() instanceof Load
    or
    expression instanceof Attribute and expression.(Attribute).getCtx() instanceof Load
    or
    expression instanceof ImportMember
    or
    expression instanceof ImportExpr
  )
}

from int expressionsWithDefinition, int expressionsWithoutDefinition
where
  // 统计有唯一定义的表达式数量
  // Count expressions with unique definitions
  expressionsWithDefinition = count(Expr expression | 
    expressionExpectsDefinition(expression) and exists(getUniqueDefinition(expression))) and
  // 统计没有唯一定义的表达式数量
  // Count expressions without unique definitions
  expressionsWithoutDefinition = count(Expr expression | 
    expressionExpectsDefinition(expression) and not exists(getUniqueDefinition(expression)))
select expressionsWithDefinition, expressionsWithoutDefinition, 
  expressionsWithDefinition * 100 / (expressionsWithDefinition + expressionsWithoutDefinition) + "%"