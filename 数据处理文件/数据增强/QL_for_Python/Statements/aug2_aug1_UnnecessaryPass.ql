/**
 * @name Unnecessary pass
 * @description Identifies redundant 'pass' statements in Python code that serve no purpose
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Determines if an expression statement represents a docstring (Unicode or Bytes literal)
predicate is_doc_string(ExprStmt docstringExpr) {
  docstringExpr.getValue() instanceof Unicode or docstringExpr.getValue() instanceof Bytes
}

// Checks if a statement list begins with a docstring within a scope
predicate has_doc_string(StmtList stmtList) {
  stmtList.getParent() instanceof Scope and
  is_doc_string(stmtList.getItem(0))
}

from Pass passStmt, StmtList containerStmts
where
  containerStmts.getAnItem() = passStmt and
  // Redundant pass occurs when there are:
  // - Exactly 2 statements without a docstring, OR
  // - More than 2 statements regardless of docstring presence
  (
    (strictcount(containerStmts.getAnItem()) = 2 and not has_doc_string(containerStmts))
    or
    strictcount(containerStmts.getAnItem()) > 2
  )
select passStmt, "Unnecessary 'pass' statement."