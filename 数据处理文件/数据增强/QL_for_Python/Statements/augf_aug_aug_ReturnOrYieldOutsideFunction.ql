/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Identifies instances where 'return', 'yield', or 'yield from' statements
 *              are incorrectly used outside function boundaries, leading to 'SyntaxError'
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

// Find statements that are improperly located outside function scope
from AstNode invalidStatement, string statementType
where 
  // Ensure the statement is not contained within any function's scope
  not exists(Function containerFunction | 
    invalidStatement.getScope() = containerFunction.getScope()
  )
  and
  (
    // Check for return statement used in invalid context
    invalidStatement instanceof Return and statementType = "return"
    or
    // Check for yield statement used in invalid context
    invalidStatement instanceof Yield and statementType = "yield"
    or
    // Check for yield from statement used in invalid context
    invalidStatement instanceof YieldFrom and statementType = "yield from"
  )
// Generate alert for the misplaced statement with descriptive error message
select invalidStatement, "'" + statementType + "' is used outside a function."