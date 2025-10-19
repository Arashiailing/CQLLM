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
 * Determines whether the given expression statement is a docstring.
 * Docstrings are typically the first statement in a module, class, or function,
 * providing documentation for the code element.
 */
predicate isDocString(ExprStmt expressionStmt) {
  // Check if the expression's value is a Unicode or Bytes literal,
  // which are commonly used for docstrings in Python
  expressionStmt.getValue() instanceof Unicode or expressionStmt.getValue() instanceof Bytes
}

/**
 * Determines whether the given statement list contains a docstring.
 * Docstrings typically appear as the first statement within a scope
 * such as a module, class, or function.
 */
predicate containsDocString(StmtList targetStmtList) {
  // Verify that the parent of the statement list is a Scope
  // and that the first statement in the list is a docstring
  targetStmtList.getParent() instanceof Scope and
  isDocString(targetStmtList.getItem(0))
}

from Pass unnecessaryPass, StmtList containingStmtList
where
  // Ensure the pass statement is contained within the statement list
  containingStmtList.getAnItem() = unnecessaryPass and
  (
    // Case 1: The statement list contains exactly 2 statements and no docstring
    strictcount(containingStmtList.getAnItem()) = 2 and not containsDocString(containingStmtList)
    or
    // Case 2: The statement list contains more than 2 statements
    strictcount(containingStmtList.getAnItem()) > 2
  )
select unnecessaryPass, "Unnecessary 'pass' statement."