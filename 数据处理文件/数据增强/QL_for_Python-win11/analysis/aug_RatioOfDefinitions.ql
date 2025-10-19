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
predicate expectsDefinition(Expr expr) {
  /* 排除内建对象 */
  /* Exclude built-in objects */
  not exists(Value builtinObject | 
    expr.pointsTo(builtinObject) and builtinObject.isBuiltin()) and
  (
    expr instanceof Name and expr.(Name).getCtx() instanceof Load
    or
    expr instanceof Attribute and expr.(Attribute).getCtx() instanceof Load
    or
    expr instanceof ImportMember
    or
    expr instanceof ImportExpr
  )
}

from int withDefinition, int withoutDefinition
where
  // 统计有唯一定义的表达式数量
  // Count expressions with unique definitions
  withDefinition = count(Expr expr | 
    expectsDefinition(expr) and exists(getUniqueDefinition(expr))) and
  // 统计没有唯一定义的表达式数量
  // Count expressions without unique definitions
  withoutDefinition = count(Expr expr | 
    expectsDefinition(expr) and not exists(getUniqueDefinition(expr)))
select withDefinition, withoutDefinition, 
  withDefinition * 100 / (withDefinition + withoutDefinition) + "%"