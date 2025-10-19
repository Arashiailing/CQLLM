/**
 * @name Unnecessary pass
 * @description Identifies redundant 'pass' statements in Python code that serve no purpose
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unnecessary-pass
 */

import python

// Determines if an expression statement represents a docstring (Unicode or Bytes literal)
predicate is_doc_string(ExprStmt docstringStatement) {
  docstringStatement.getValue() instanceof Unicode or docstringStatement.getValue() instanceof Bytes
}

// Checks if a statement list begins with a docstring within a scope
predicate has_doc_string(StmtList statementBlock) {
  statementBlock.getParent() instanceof Scope and
  is_doc_string(statementBlock.getItem(0))
}

from Pass passStatement, StmtList containingBlock
where
  containingBlock.getAnItem() = passStatement and
  // Redundant pass occurs when there are:
  // - Exactly 2 statements without a docstring, OR
  // - More than 2 statements regardless of docstring presence
  (
    (strictcount(containingBlock.getAnItem()) = 2 and not has_doc_string(containingBlock))
    or
    strictcount(containingBlock.getAnItem()) > 2
  )
select passStatement, "Unnecessary 'pass' statement."