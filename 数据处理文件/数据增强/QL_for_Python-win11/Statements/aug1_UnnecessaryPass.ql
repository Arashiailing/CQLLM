/**
 * @name Unnecessary pass
 * @description Detects redundant 'pass' statements in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Helper predicate to determine if an expression statement is a docstring
predicate is_doc_string(ExprStmt exprStmt) {
  // Check if the expression value is a Unicode or Bytes literal
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

// Helper predicate to check if a statement list contains a docstring
predicate has_doc_string(StmtList statements) {
  // Verify the parent is a Scope and the first statement is a docstring
  statements.getParent() instanceof Scope and
  is_doc_string(statements.getItem(0))
}

// Helper predicate to identify statement lists where a pass statement is unnecessary
predicate is_unnecessary_pass_context(StmtList stmtList) {
  exists(Pass passStmt |
    stmtList.getAnItem() = passStmt and
    (
      // Case 1: Exactly 2 statements without a docstring
      strictcount(stmtList.getAnItem()) = 2 and not has_doc_string(stmtList)
      or
      // Case 2: More than 2 statements
      strictcount(stmtList.getAnItem()) > 2
    )
  )
}

from Pass passStmt, StmtList stmtList
where
  stmtList.getAnItem() = passStmt and
  is_unnecessary_pass_context(stmtList)
select passStmt, "Unnecessary 'pass' statement."