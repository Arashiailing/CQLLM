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
 * Determines if an expression statement is a docstring.
 * Docstrings typically appear as the first statement in modules, classes, or functions.
 */
predicate isDocString(ExprStmt docStringCandidate) {
  // Check if the expression value is Unicode or Bytes, common types for docstrings
  docStringCandidate.getValue() instanceof Unicode or 
  docStringCandidate.getValue() instanceof Bytes
}

/**
 * Determines if a statement list contains a docstring.
 * Docstrings usually appear as the first statement within a Scope.
 */
predicate containsDocString(StmtList stmtList) {
  // Verify the parent is a Scope and the first statement is a docstring
  stmtList.getParent() instanceof Scope and
  isDocString(stmtList.getItem(0))
}

from Pass passStatement, StmtList parentStmtList
where
  // Ensure the statement list contains the pass statement
  parentStmtList.getAnItem() = passStatement and
  (
    // Case 1: Exactly 2 statements without a docstring
    strictcount(parentStmtList.getAnItem()) = 2 and 
    not containsDocString(parentStmtList)
    or
    // Case 2: More than 2 statements
    strictcount(parentStmtList.getAnItem()) > 2
  )
select passStatement, "Unnecessary 'pass' statement."