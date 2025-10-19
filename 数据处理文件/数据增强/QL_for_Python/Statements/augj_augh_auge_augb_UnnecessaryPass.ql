/**
 * @name Unnecessary pass
 * @description Identifies redundant 'pass' statements in Python code blocks
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Determines if an expression statement is a docstring (Unicode/Bytes literal)
predicate is_docstring(ExprStmt docstringStmt) {
  docstringStmt.getValue() instanceof Unicode or docstringStmt.getValue() instanceof Bytes
}

// Checks if a statement block starts with a docstring
predicate contains_docstring(StmtList parentBlock) {
  parentBlock.getParent() instanceof Scope and
  is_docstring(parentBlock.getItem(0))
}

// Find redundant pass statements and their containing blocks
from Pass passStatement, StmtList parentBlock, int statementCount
where
  // Pass statement must be in the block
  parentBlock.getAnItem() = passStatement and
  // Calculate total statements in the block
  statementCount = strictcount(parentBlock.getAnItem()) and
  // Check redundancy conditions:
  //   a) Block has >2 statements (pass + others), OR
  //   b) Block has exactly 2 statements without docstring
  (
    statementCount > 2
    or
    (statementCount = 2 and not contains_docstring(parentBlock))
  )
select passStatement, "Unnecessary 'pass' statement."