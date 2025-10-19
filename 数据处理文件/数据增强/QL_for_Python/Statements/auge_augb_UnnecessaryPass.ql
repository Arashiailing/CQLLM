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
predicate is_doc_string(ExprStmt docStringStmt) {
  // Check if the expression value is of Unicode or Bytes type
  docStringStmt.getValue() instanceof Unicode or docStringStmt.getValue() instanceof Bytes
}

// Predicate to check if a statement list contains a docstring
predicate has_doc_string(StmtList parentStmtList) {
  // Verify that the parent of the statement list is a Scope
  // and the first statement is a docstring
  parentStmtList.getParent() instanceof Scope and
  is_doc_string(parentStmtList.getItem(0))
}

// Select Pass statements and their containing statement lists
from Pass unnecessaryPass, StmtList containerStmtList
where
  // The pass statement is an item in the statement list
  containerStmtList.getAnItem() = unnecessaryPass and
  // The list has either more than 2 items, or exactly 2 items without a docstring
  (strictcount(containerStmtList.getAnItem()) > 2 or 
   (strictcount(containerStmtList.getAnItem()) = 2 and not has_doc_string(containerStmtList)))
select unnecessaryPass, "Unnecessary 'pass' statement."