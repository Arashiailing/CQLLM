/**
 * @name Module is imported more than once
 * @description Importing a module a second time has no effect and impairs readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// 定义一个谓词函数，用于判断导入语句是否为简单导入（不包含属性）
predicate is_simple_import(Import imp) { not exists(Attribute a | imp.contains(a)) }

// 定义一个谓词函数，用于判断是否存在重复导入的情况
predicate double_import(Import original, Import duplicate, Module m) {
  // 确保原始导入和重复导入不是同一个导入
  original != duplicate and
  // 确保两个导入都是简单导入
  is_simple_import(original) and
  is_simple_import(duplicate) and
  /* 导入的是同一个模块 */
  exists(ImportExpr e1, ImportExpr e2 |
    e1.getName() = m.getName() and
    e2.getName() = m.getName() and
    e1 = original.getAName().getValue() and
    e2 = duplicate.getAName().getValue()
  ) and
  // 确保两个导入的别名相同
  original.getAName().getAsname().(Name).getId() = duplicate.getAName().getAsname().(Name).getId() and
  exists(Module enclosing |
    original.getScope() = enclosing and
    duplicate.getEnclosingModule() = enclosing and
    (
      /* 重复导入不在顶层作用域 */
      duplicate.getScope() != enclosing
      or
      /* 原始导入在代码中的位置优先于重复导入 */
      original.getAnEntryNode().dominates(duplicate.getAnEntryNode())
    )
  )
}

// 查询所有存在重复导入的情况，并选择重复导入及其相关信息进行报告
from Import original, Import duplicate, Module m
where double_import(original, duplicate, m)
select duplicate,
  "This import of module " + m.getName() + " is redundant, as it was previously imported $@.",
  original, "on line " + original.getLocation().getStartLine().toString()
