/**
 * @name Ratio of jump-to-definitions computed
 * 计算可跳转到定义的表达式比例统计
 */

import python
import analysis.DefinitionTracking

// 定义谓词：识别需要定义追踪的表达式类型
predicate requiresDefinitionTracking(Expr expr) {
  /* 排除内建对象（如len、tuple等） */
  not exists(Value builtin | expr.pointsTo(builtin) and builtin.isBuiltin()) and
  (
    // 加载上下文中的名称引用
    expr instanceof Name and expr.(Name).getCtx() instanceof Load
    or
    // 加载上下文中的属性访问
    expr instanceof Attribute and expr.(Attribute).getCtx() instanceof Load
    or
    // 导入成员引用
    expr instanceof ImportMember
    or
    // 导入表达式
    expr instanceof ImportExpr
  )
}

from int definedCount, int undefinedCount
where
  // 统计存在唯一定义的表达式数量
  definedCount = count(Expr expr | 
    requiresDefinitionTracking(expr) and 
    exists(getUniqueDefinition(expr))
  ) and
  // 统计不存在唯一定义的表达式数量
  undefinedCount = count(Expr expr | 
    requiresDefinitionTracking(expr) and 
    not exists(getUniqueDefinition(expr))
  )
select 
  definedCount, 
  undefinedCount, 
  definedCount * 100 / (definedCount + undefinedCount) + "%"