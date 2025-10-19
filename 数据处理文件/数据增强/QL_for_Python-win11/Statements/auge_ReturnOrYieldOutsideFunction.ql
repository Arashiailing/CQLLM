/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return', 'yield', or 'yield from' statements used outside of a function scope,
 *              which would cause a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements that are improperly placed outside function scopes
from AstNode invalidStmt, string stmtType
where
  // Ensure the statement is not within any function's scope
  not invalidStmt.getScope() instanceof Function and
  (
    // Check for return statements
    invalidStmt instanceof Return and stmtType = "return"
    or
    // Check for yield statements
    invalidStmt instanceof Yield and stmtType = "yield"
    or
    // Check for yield from statements
    invalidStmt instanceof YieldFrom and stmtType = "yield from"
  )
// Report the problematic statement with an appropriate error message
select invalidStmt, "'" + stmtType + "' is used outside a function."