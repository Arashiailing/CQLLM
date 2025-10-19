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
 * Identifies docstring statements (Unicode/Bytes literals)
 * Typically appears as the first statement in modules, classes, or functions
 */
predicate isDocString(ExprStmt docstringStmt) {
  // Verify the statement contains a string literal
  docstringStmt.getValue() instanceof Unicode or docstringStmt.getValue() instanceof Bytes
}

/**
 * Checks if a statement block starts with a docstring
 * Docstrings must be the initial statement in a scope (module/class/function)
 */
predicate hasLeadingDocstring(StmtList bodyStmts) {
  // Ensure parent is a scope and first statement is a docstring
  bodyStmts.getParent() instanceof Scope and
  isDocString(bodyStmts.getItem(0))
}

from Pass redundantPass, StmtList parentBlock
where
  // Verify the pass statement belongs to this statement block
  parentBlock.getAnItem() = redundantPass and
  (
    // Case 1: Exactly 2 statements without docstring
    strictcount(parentBlock.getAnItem()) = 2 and 
    not hasLeadingDocstring(parentBlock)
    or
    // Case 2: More than 2 statements (docstring irrelevant)
    strictcount(parentBlock.getAnItem()) > 2
  )
select redundantPass, "Unnecessary 'pass' statement."