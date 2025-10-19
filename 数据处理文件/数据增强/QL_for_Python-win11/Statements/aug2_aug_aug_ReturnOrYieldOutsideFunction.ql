/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Identifies instances where 'return', 'yield', or 'yield from' statements
 *              are incorrectly placed outside function scope, leading to 'SyntaxError'
 *              during Python code execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Find statements that are improperly located outside function boundaries
from AstNode invalidStmt, string stmtType
where 
  // Ensure the statement is not contained within any function's scope
  not exists(Function parentFunction | 
    invalidStmt.getScope() = parentFunction.getScope()
  ) and
  // Determine the type of invalid statement
  (
    // Case 1: Return statement used outside function
    invalidStmt instanceof Return and stmtType = "return"
    or
    // Case 2: Yield statement used outside function
    invalidStmt instanceof Yield and stmtType = "yield"
    or
    // Case 3: Yield from statement used outside function
    invalidStmt instanceof YieldFrom and stmtType = "yield from"
  )
// Output the identified statement with a descriptive error message
select invalidStmt, "'" + stmtType + "' is used outside a function."