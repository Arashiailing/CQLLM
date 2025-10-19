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

// Identifies expression statements that represent docstrings (Unicode or Bytes literals)
predicate is_doc_string(ExprStmt docstringCandidate) {
  docstringCandidate.getValue() instanceof Unicode or docstringCandidate.getValue() instanceof Bytes
}

// Determines if a statement list starts with a docstring within a scope
predicate has_doc_string(StmtList targetStmtList) {
  targetStmtList.getParent() instanceof Scope and
  is_doc_string(targetStmtList.getItem(0))
}

from Pass redundantPass, StmtList parentStmtList
where
  parentStmtList.getAnItem() = redundantPass and
  // Redundant pass conditions:
  // - Exactly 2 statements without docstring, OR
  // - More than 2 statements regardless of docstring presence
  (
    (strictcount(parentStmtList.getAnItem()) = 2 and not has_doc_string(parentStmtList))
    or
    strictcount(parentStmtList.getAnItem()) > 2
  )
select redundantPass, "Unnecessary 'pass' statement."