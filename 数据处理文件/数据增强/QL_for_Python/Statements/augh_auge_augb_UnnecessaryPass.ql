/**
 * @name Unnecessary pass
 * @description Detects redundant 'pass' statements in Python code blocks
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
from Pass passStmt, StmtList containingBlock, int blockStmtCount
where
  // Pass statement must be in the block
  containingBlock.getAnItem() = passStmt and
  // Calculate total statements in the block
  blockStmtCount = strictcount(containingBlock.getAnItem()) and
  // Block has either:
  //   a) More than 2 statements (pass + others), OR
  //   b) Exactly 2 statements without a docstring
  (blockStmtCount > 2 or 
   (blockStmtCount = 2 and not contains_docstring(containingBlock)))
select passStmt, "Unnecessary 'pass' statement."