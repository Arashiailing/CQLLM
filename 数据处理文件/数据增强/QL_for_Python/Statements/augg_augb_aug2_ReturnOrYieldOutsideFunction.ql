/**
 * @name Misplaced return or yield statements outside function boundaries
 * @description Identifies incorrect placement of 'return', 'yield', or 'yield from' statements
 *              outside of function definitions, which will result in SyntaxError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Locate statements that are incorrectly positioned outside function definitions
from AstNode stmt, string stmtType
where
  // Check if the statement is one of the problematic types
  (
    stmt instanceof Return and stmtType = "return"
    or
    stmt instanceof Yield and stmtType = "yield"
    or
    stmt instanceof YieldFrom and stmtType = "yield from"
  )
  and
  // Verify the statement is not within any function scope
  not stmt.getScope() instanceof Function
// Produce alert with the problematic statement and explanatory message
select stmt, "Statement '" + stmtType + "' is used outside a function definition."