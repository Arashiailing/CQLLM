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

// Helper predicate to identify if an expression statement represents a docstring
predicate is_doc_string(ExprStmt expressionStmt) {
  // Verify that the expression value is either a Unicode string or a Bytes literal
  expressionStmt.getValue() instanceof Unicode or expressionStmt.getValue() instanceof Bytes
}

// Helper predicate to determine if a statement list begins with a docstring
predicate has_doc_string(StmtList statements) {
  // Ensure the parent is a Scope and the first statement is a docstring
  statements.getParent() instanceof Scope and
  is_doc_string(statements.getItem(0))
}

// Main query to identify unnecessary pass statements
from Pass passStatement, StmtList parentStatements
where
  // The pass statement must be contained within the statement list
  parentStatements.getAnItem() = passStatement and
  // Check if the statement list has more than 2 items,
  // or exactly 2 items without a docstring
  (strictcount(parentStatements.getAnItem()) > 2 or 
   (strictcount(parentStatements.getAnItem()) = 2 and not has_doc_string(parentStatements)))
select passStatement, "Unnecessary 'pass' statement."