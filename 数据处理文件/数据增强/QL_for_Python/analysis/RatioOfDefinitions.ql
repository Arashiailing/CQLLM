/**
 * @name Ratio of jump-to-definitions computed
 * 计算跳转到定义的比例
 */

import python
import analysis.DefinitionTracking

// 定义一个谓词函数，用于判断表达式是否希望有定义
predicate want_to_have_definition(Expr e) {
  /* not builtin object like len, tuple, etc. */
  // 排除内建对象如len、tuple等
  not exists(Value builtin | e.pointsTo(builtin) and builtin.isBuiltin()) and
  (
    e instanceof Name and e.(Name).getCtx() instanceof Load
    // 如果表达式是名称并且其上下文是加载操作
    or
    e instanceof Attribute and e.(Attribute).getCtx() instanceof Load
    // 如果表达式是属性并且其上下文是加载操作
    or
    e instanceof ImportMember
    // 如果表达式是导入成员
    or
    e instanceof ImportExpr
    // 如果表达式是导入表达式
  )
}

from int yes, int no
where
  yes = count(Expr e | want_to_have_definition(e) and exists(getUniqueDefinition(e))) and
  // 统计有唯一定义的表达式数量
  no = count(Expr e | want_to_have_definition(e) and not exists(getUniqueDefinition(e)))
  // 统计没有唯一定义的表达式数量
select yes, no, yes * 100 / (yes + no) + "%"
  // 选择有定义和无定义的数量以及它们的比例
