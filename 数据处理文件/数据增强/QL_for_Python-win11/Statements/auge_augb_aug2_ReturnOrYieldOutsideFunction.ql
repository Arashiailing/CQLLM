/**
 * @name Incorrect usage of 'return' or 'yield' outside function scope
 * @description Detects 'return', 'yield', or 'yield from' statements that are incorrectly
 *              placed outside function definitions, causing SyntaxError during execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements that are problematic when used outside functions
from AstNode problematicStmt, string stmtType
where
  // Check if the statement is a return, yield, or yield from
  (
    problematicStmt instanceof Return and stmtType = "return"
    or
    problematicStmt instanceof Yield and stmtType = "yield"
    or
    problematicStmt instanceof YieldFrom and stmtType = "yield from"
  )
  and
  // Verify the statement is not within any function scope
  not problematicStmt.getScope() instanceof Function
// Generate alert with statement and contextual message
select problematicStmt, "Statement '" + stmtType + "' is used outside a function definition."