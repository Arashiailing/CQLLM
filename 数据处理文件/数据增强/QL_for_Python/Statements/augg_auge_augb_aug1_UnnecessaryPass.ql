/**
 * @name Unnecessary pass
 * @description Detects redundant 'pass' statements in Python code that can be safely removed
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Predicate to identify docstring expressions (Unicode/Bytes literals)
predicate is_doc_string(ExprStmt docstringStmt) {
  // Check if the expression value is a string literal
  docstringStmt.getValue() instanceof Unicode or docstringStmt.getValue() instanceof Bytes
}

// Predicate to verify if a statement list starts with a docstring
predicate has_doc_string(StmtList stmtList) {
  // Confirm parent is a Scope and first statement is a docstring
  stmtList.getParent() instanceof Scope and
  is_doc_string(stmtList.getItem(0))
}

// Predicate to identify contexts where pass statements are redundant
predicate is_unnecessary_pass_context(StmtList stmtList) {
  // Check statement count conditions for redundancy
  (
    // Case 1: Exactly 2 statements without docstring
    strictcount(stmtList.getAnItem()) = 2 and not has_doc_string(stmtList)
    or
    // Case 2: More than 2 statements
    strictcount(stmtList.getAnItem()) > 2
  )
}

from Pass redundantPass, StmtList parentStmts
where
  // Ensure pass statement is in the statement list
  parentStmts.getAnItem() = redundantPass and
  // Verify redundancy context
  is_unnecessary_pass_context(parentStmts)
select redundantPass, "Unnecessary 'pass' statement."