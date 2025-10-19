/**
 * @name Unnecessary pass
 * @description Identifies redundant 'pass' statements in Python code that can be safely removed
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Helper predicate to determine if an expression statement represents a docstring
predicate is_doc_string(ExprStmt docExprStmt) {
  // Verify the expression value is either a Unicode or Bytes literal
  docExprStmt.getValue() instanceof Unicode or docExprStmt.getValue() instanceof Bytes
}

// Helper predicate to check if a statement list begins with a docstring
predicate has_doc_string(StmtList statementList) {
  // Ensure the parent is a Scope and the first statement is a docstring
  statementList.getParent() instanceof Scope and
  is_doc_string(statementList.getItem(0))
}

// Helper predicate to identify contexts where a pass statement is redundant
predicate is_unnecessary_pass_context(StmtList statementList) {
  exists(Pass unnecessaryPass |
    statementList.getAnItem() = unnecessaryPass and
    (
      // Scenario 1: Statement list has exactly 2 items and no docstring
      strictcount(statementList.getAnItem()) = 2 and not has_doc_string(statementList)
      or
      // Scenario 2: Statement list contains more than 2 items
      strictcount(statementList.getAnItem()) > 2
    )
  )
}

from Pass unnecessaryPass, StmtList parentStmtList
where
  parentStmtList.getAnItem() = unnecessaryPass and
  is_unnecessary_pass_context(parentStmtList)
select unnecessaryPass, "Unnecessary 'pass' statement."