/**
 * @name Unnecessary pass
 * @description Identifies unnecessary 'pass' statements in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Predicate to determine if an expression statement is a docstring
predicate is_doc_string(ExprStmt exprStmt) {
  // Check if the expression value is of Unicode or Bytes type
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

// Predicate to check if a statement list contains a docstring
predicate has_doc_string(StmtList statementList) {
  // Verify that the parent of the statement list is a Scope
  // and the first statement is a docstring
  statementList.getParent() instanceof Scope and
  is_doc_string(statementList.getItem(0))
}

// Select Pass statements and their containing statement lists
from Pass passStmt, StmtList stmtList
where
  // The pass statement is an item in the statement list
  stmtList.getAnItem() = passStmt and
  // The list has either more than 2 items, or exactly 2 items without a docstring
  (strictcount(stmtList.getAnItem()) > 2 or 
   (strictcount(stmtList.getAnItem()) = 2 and not has_doc_string(stmtList)))
select passStmt, "Unnecessary 'pass' statement."