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

// Helper predicate to check if an expression statement is a docstring
predicate is_doc_string(ExprStmt exprStmt) {
  // Verify the expression value is either a Unicode string or Bytes literal
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

// Helper predicate to determine if a statement list starts with a docstring
predicate has_doc_string(StmtList stmtList) {
  // Ensure parent is a Scope and first statement is a docstring
  stmtList.getParent() instanceof Scope and
  is_doc_string(stmtList.getItem(0))
}

// Main query to detect unnecessary pass statements
from Pass passStmt, StmtList stmtList
where
  // Verify the pass statement is contained in the statement list
  stmtList.getAnItem() = passStmt and
  // Check if the statement list contains more than 2 items,
  // or exactly 2 items without a leading docstring
  (strictcount(stmtList.getAnItem()) > 2 or 
   (strictcount(stmtList.getAnItem()) = 2 and not has_doc_string(stmtList)))
select passStmt, "Unnecessary 'pass' statement."