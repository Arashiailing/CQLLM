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

/**
 * Identifies if an expression statement serves as a docstring.
 * Docstrings are string literals that appear at the beginning of modules,
 * classes, or functions to document their purpose.
 */
predicate isDocString(ExprStmt docStringExpr) {
  // A docstring is represented as either a Unicode or Bytes literal
  docStringExpr.getValue() instanceof Unicode or docStringExpr.getValue() instanceof Bytes
}

/**
 * Checks if a statement list begins with a docstring.
 * This is typically the first statement in a module, class, or function body.
 */
predicate containsDocString(StmtList stmtListWithDoc) {
  // The statement list must belong to a scope and have a docstring as its first element
  stmtListWithDoc.getParent() instanceof Scope and
  isDocString(stmtListWithDoc.getItem(0))
}

from Pass redundantPass, StmtList parentStmtList
where
  // The redundant pass statement must be contained within the parent statement list
  parentStmtList.getAnItem() = redundantPass and
  (
    // Scenario 1: Statement list has exactly 2 items without a docstring
    strictcount(parentStmtList.getAnItem()) = 2 and 
    not containsDocString(parentStmtList)
    or
    // Scenario 2: Statement list has more than 2 items
    strictcount(parentStmtList.getAnItem()) > 2
  )
select redundantPass, "Unnecessary 'pass' statement."