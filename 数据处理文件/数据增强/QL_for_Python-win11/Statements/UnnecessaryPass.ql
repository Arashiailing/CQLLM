/**
 * @name Unnecessary pass
 * @description Unnecessary 'pass' statement
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// 定义一个谓词函数，用于判断表达式语句是否为文档字符串
predicate is_doc_string(ExprStmt s) {
  // 检查表达式的值是否为Unicode或Bytes类型
  s.getValue() instanceof Unicode or s.getValue() instanceof Bytes
}

// 定义一个谓词函数，用于判断语句列表是否包含文档字符串
predicate has_doc_string(StmtList stmts) {
  // 检查语句列表的父节点是否为Scope，并且第一个语句是否为文档字符串
  stmts.getParent() instanceof Scope and
  is_doc_string(stmts.getItem(0))
}

// 从Pass和StmtList中选择数据
from Pass p, StmtList list
where
  // 条件1：列表中的某个项是Pass实例
  list.getAnItem() = p and
  (
    // 条件2：列表项数等于2且不包含文档字符串，或者列表项数大于2
    strictcount(list.getAnItem()) = 2 and not has_doc_string(list)
    or
    strictcount(list.getAnItem()) > 2
  )
select p, "Unnecessary 'pass' statement."
// 选择符合条件的Pass实例，并标记为“不必要的'pass'语句”
