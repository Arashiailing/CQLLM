/**
 * @name Unnecessary pass
 * @description Detects redundant 'pass' statements in Python code that serve no functional purpose
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Determines if an expression statement is a docstring (Unicode or Bytes literal)
predicate is_doc_string(ExprStmt docStringStmt) {
  docStringStmt.getValue() instanceof Unicode or docStringStmt.getValue() instanceof Bytes
}

// Checks if a statement block starts with a docstring within a scope
predicate has_doc_string(StmtList stmtList) {
  stmtList.getParent() instanceof Scope and
  is_doc_string(stmtList.getItem(0))
}

from Pass redundantPass, StmtList parentBlock
where
  parentBlock.getAnItem() = redundantPass and
  exists(int totalStmts |
    totalStmts = strictcount(parentBlock.getAnItem()) and
    (
      // Case 1: Exactly 2 statements without a docstring
      (totalStmts = 2 and not has_doc_string(parentBlock)) 
      or 
      // Case 2: More than 2 statements regardless of docstring presence
      totalStmts > 2
    )
  )
select redundantPass, "Unnecessary 'pass' statement."