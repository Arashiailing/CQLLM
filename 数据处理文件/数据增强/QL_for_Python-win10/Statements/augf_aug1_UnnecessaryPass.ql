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

// Helper predicate to check if an expression statement is a docstring
predicate is_doc_string(ExprStmt docStringExpr) {
  // Verify the expression value is either a Unicode or Bytes literal
  docStringExpr.getValue() instanceof Unicode or docStringExpr.getValue() instanceof Bytes
}

// Helper predicate to determine if a statement list contains a docstring
predicate has_doc_string(StmtList stmtList) {
  // Ensure parent is a Scope and the first statement is a docstring
  stmtList.getParent() instanceof Scope and
  is_doc_string(stmtList.getItem(0))
}

// Helper predicate to identify contexts where 'pass' statements are unnecessary
predicate is_unnecessary_pass_context(StmtList parentStmtList) {
  exists(Pass redundantPass |
    parentStmtList.getAnItem() = redundantPass and
    (
      // Case 1: Exactly 2 statements without a docstring
      strictcount(parentStmtList.getAnItem()) = 2 and not has_doc_string(parentStmtList)
      or
      // Case 2: More than 2 statements present
      strictcount(parentStmtList.getAnItem()) > 2
    )
  )
}

from Pass redundantPass, StmtList parentStmtList
where
  parentStmtList.getAnItem() = redundantPass and
  is_unnecessary_pass_context(parentStmtList)
select redundantPass, "Unnecessary 'pass' statement."