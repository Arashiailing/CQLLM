/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return' or 'yield' statements used outside function scope,
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

// Identify statements that are improperly placed outside function definitions
from AstNode stmt, string stmtType
where 
  // Verify the statement is not contained within any function's scope
  not exists(Function func | stmt.getScope() = func.getScope()) and
  (
    // Case 1: Return statement outside function
    stmt instanceof Return and stmtType = "return"
    or
    // Case 2: Yield expression outside function
    stmt instanceof Yield and stmtType = "yield"
    or
    // Case 3: Yield from expression outside function
    stmt instanceof YieldFrom and stmtType = "yield from"
  )
// Report violating statements with descriptive error messages
select stmt, "'" + stmtType + "' is used outside a function."