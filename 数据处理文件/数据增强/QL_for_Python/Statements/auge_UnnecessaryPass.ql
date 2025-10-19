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

// 判断表达式语句是否为文档字符串
predicate is_doc_string(ExprStmt exprStmt) {
  // 表达式的值是Unicode或Bytes类型
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

// 判断语句列表是否包含文档字符串
predicate has_doc_string(StmtList stmtList) {
  // 语句列表的父节点是Scope，且第一个语句是文档字符串
  stmtList.getParent() instanceof Scope and
  is_doc_string(stmtList.getItem(0))
}

// 查找不必要的pass语句
from Pass passStmt
where exists(StmtList containingList |
  containingList.getAnItem() = passStmt and
  (
    // 列表项数为2且不含文档字符串，或列表项数大于2
    (strictcount(containingList.getAnItem()) = 2 and not has_doc_string(containingList))
    or
    strictcount(containingList.getAnItem()) > 2
  )
)
select passStmt, "Unnecessary 'pass' statement."