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
 * Docstrings are typically the first statement in modules, classes, or functions.
 */
predicate isDocString(ExprStmt exprStmt) {
  // Check if the expression value is a Unicode or Bytes literal
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

/**
 * Checks if a statement list contains a docstring as its first element.
 * Docstrings must be the initial statement in a scope (module/class/function).
 */
predicate containsDocString(StmtList stmtList) {
  // Verify parent is a scope and first statement is a docstring
  stmtList.getParent() instanceof Scope and
  isDocString(stmtList.getItem(0))
}

from Pass unnecessaryPass, StmtList enclosingStmtList
where
  // The pass statement must be contained in this statement list
  enclosingStmtList.getAnItem() = unnecessaryPass and
  (
    // Case 1: Exactly 2 statements without docstring
    strictcount(enclosingStmtList.getAnItem()) = 2 and 
    not containsDocString(enclosingStmtList)
    or
    // Case 2: More than 2 statements (docstring presence irrelevant)
    strictcount(enclosingStmtList.getAnItem()) > 2
  )
select unnecessaryPass, "Unnecessary 'pass' statement."