/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description Identifies statements ('return', 'yield', or 'yield from') that are incorrectly placed outside function definitions, leading to runtime 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Find statements that are only valid within function scope
from AstNode misplacedStmt, string statementKind
where 
  // Verify the statement is not enclosed within any function
  not exists(Function containerFunc | misplacedStmt.getScope() = containerFunc.getScope())
  and
  // Check if the statement is one of the restricted types
  (
    misplacedStmt instanceof Return and statementKind = "return"
    or
    misplacedStmt instanceof Yield and statementKind = "yield"
    or
    misplacedStmt instanceof YieldFrom and statementKind = "yield from"
  )
// Generate an alert for the misplaced statement with a descriptive message
select misplacedStmt, "'" + statementKind + "' is used outside a function."