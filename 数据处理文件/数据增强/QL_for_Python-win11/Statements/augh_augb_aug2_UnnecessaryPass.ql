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
 * Identifies whether an expression statement serves as a docstring.
 * Docstrings are conventionally the first statement in modules, classes, or functions.
 */
predicate isDocString(ExprStmt docstringCandidate) {
  // Verify that the expression's value is either a Unicode or Bytes literal
  docstringCandidate.getValue() instanceof Unicode or docstringCandidate.getValue() instanceof Bytes
}

/**
 * Determines if a statement list starts with a docstring.
 * Docstrings must appear as the first statement within a scope (module/class/function).
 */
predicate containsDocString(StmtList stmtSequence) {
  // Ensure the parent is a scope and the initial statement is a docstring
  stmtSequence.getParent() instanceof Scope and
  isDocString(stmtSequence.getItem(0))
}

from Pass redundantPass, StmtList containerStmtList
where
  // The pass statement must be part of this statement list
  containerStmtList.getAnItem() = redundantPass and
  // Check if the statement list has more than one statement
  strictcount(containerStmtList.getAnItem()) > 1 and
  // If there are exactly 2 statements, ensure there's no docstring
  (strictcount(containerStmtList.getAnItem()) > 2 or not containsDocString(containerStmtList))
select redundantPass, "Unnecessary 'pass' statement."