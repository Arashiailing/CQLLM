/**
 * @name Unnecessary pass
 * @description Identifies unnecessary 'pass' statements in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Predicate to identify docstring statements (Unicode/Bytes string literals)
predicate is_doc_string(ExprStmt stringLiteralStmt) {
  // Check if the expression value is either a Unicode or Bytes string
  stringLiteralStmt.getValue() instanceof Unicode or 
  stringLiteralStmt.getValue() instanceof Bytes
}

// Predicate to determine if a statement list starts with a docstring
predicate has_doc_string(StmtList stmtList) {
  // Verify the parent is a scope and the first statement is a docstring
  exists(Scope scope | scope = stmtList.getParent()) and
  is_doc_string(stmtList.getItem(0))
}

// Select unnecessary pass statements and their containing contexts
from Pass redundantPass, StmtList enclosingStmtList
where
  // Ensure the pass statement belongs to the statement list
  enclosingStmtList.getAnItem() = redundantPass and
  // Check if the list has more than 2 statements OR exactly 2 without a docstring
  (strictcount(enclosingStmtList.getAnItem()) > 2 or 
   (strictcount(enclosingStmtList.getAnItem()) = 2 and 
    not has_doc_string(enclosingStmtList)))
select redundantPass, "Unnecessary 'pass' statement."