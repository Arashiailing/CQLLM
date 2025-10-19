/**
 * @name Unnecessary pass
 * @description Identifies redundant 'pass' statements in Python code that can be safely removed
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Predicate to check if an expression statement represents a docstring
predicate is_docstring_expr(ExprStmt exprStmt) {
  // Verify the expression value is either a Unicode or Bytes literal
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

// Predicate to determine if a statement list begins with a docstring
predicate contains_docstring(StmtList statements) {
  // Ensure the parent is a Scope and the initial statement is a docstring
  statements.getParent() instanceof Scope and
  is_docstring_expr(statements.getItem(0))
}

// Predicate to identify contexts where a pass statement is redundant
predicate has_redundant_pass(StmtList stmtList) {
  exists(Pass passNode |
    stmtList.getAnItem() = passNode and
    (
      // Scenario 1: Statement list has exactly 2 items and no docstring
      strictcount(stmtList.getAnItem()) = 2 and not contains_docstring(stmtList)
      or
      // Scenario 2: Statement list contains more than 2 items
      strictcount(stmtList.getAnItem()) > 2
    )
  )
}

from Pass passNode, StmtList containerList
where
  containerList.getAnItem() = passNode and
  has_redundant_pass(containerList)
select passNode, "Unnecessary 'pass' statement."