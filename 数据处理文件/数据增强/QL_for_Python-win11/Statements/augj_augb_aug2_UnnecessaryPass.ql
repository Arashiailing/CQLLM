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
 * Identifies whether an expression statement represents a docstring.
 * Docstrings are typically positioned as the first statement within modules, classes, or functions.
 */
predicate isDocumentationString(ExprStmt exprStmt) {
  // Validate that the expression's value is either a Unicode or Bytes literal
  exprStmt.getValue() instanceof Unicode or exprStmt.getValue() instanceof Bytes
}

/**
 * Verifies if a statement list includes a docstring as its initial element.
 * Docstrings must appear as the first statement within a scope (module/class/function).
 */
predicate hasDocumentationString(StmtList stmtList) {
  // Confirm that the parent is a scope and the first statement is a docstring
  stmtList.getParent() instanceof Scope and
  isDocumentationString(stmtList.getItem(0))
}

from Pass redundantPass, StmtList parentStmtList
where
  // The pass statement must be contained within this statement list
  parentStmtList.getAnItem() = redundantPass and
  (
    // Scenario 1: Statement list contains exactly 2 statements without a docstring
    strictcount(parentStmtList.getAnItem()) = 2 and 
    not hasDocumentationString(parentStmtList)
    or
    // Scenario 2: Statement list contains more than 2 statements (docstring presence is irrelevant)
    strictcount(parentStmtList.getAnItem()) > 2
  )
select redundantPass, "Unnecessary 'pass' statement."