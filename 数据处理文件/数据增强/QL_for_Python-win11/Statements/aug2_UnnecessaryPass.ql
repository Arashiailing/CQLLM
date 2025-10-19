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

/**
 * 判断给定的表达式语句是否为文档字符串。
 * 文档字符串通常是模块、类或函数的第一个语句，用于提供文档说明。
 */
predicate isDocString(ExprStmt exprStmt) {
  // 检查表达式的值是否为Unicode或Bytes类型，这两种类型通常用于表示文档字符串
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

/**
 * 判断给定的语句列表是否包含文档字符串。
 * 文档字符串通常作为Scope（如模块、类或函数）的第一个语句出现。
 */
predicate containsDocString(StmtList statementList) {
  // 检查语句列表的父节点是否为Scope，并且第一个语句是否为文档字符串
  statementList.getParent() instanceof Scope and
  isDocString(statementList.getItem(0))
}

from Pass passStmt, StmtList stmtList
where
  // 条件1：语句列表中包含该pass语句
  stmtList.getAnItem() = passStmt and
  (
    // 条件2a：语句列表恰好包含2个语句且不包含文档字符串
    strictcount(stmtList.getAnItem()) = 2 and not containsDocString(stmtList)
    or
    // 条件2b：语句列表包含超过2个语句
    strictcount(stmtList.getAnItem()) > 2
  )
select passStmt, "Unnecessary 'pass' statement."