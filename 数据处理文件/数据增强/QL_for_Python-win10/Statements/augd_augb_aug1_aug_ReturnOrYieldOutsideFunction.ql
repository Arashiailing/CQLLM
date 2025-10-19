/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description Detects misplaced 'return', 'yield', or 'yield from' statements that appear outside function boundaries, which would cause Python to raise a SyntaxError during execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Find all statements that are improperly placed outside function boundaries
from AstNode invalidStmt, string statementType
where 
  // Ensure the statement is not contained within any function's scope
  not exists(Function enclosingFunction | invalidStmt.getScope() = enclosingFunction.getScope()) and
  (
    // Identify return statements used in invalid context
    invalidStmt instanceof Return and statementType = "return"
    or
    // Identify yield statements used in invalid context
    invalidStmt instanceof Yield and statementType = "yield"
    or
    // Identify yield from statements used in invalid context
    invalidStmt instanceof YieldFrom and statementType = "yield from"
  )
// Generate alert with descriptive error message
select invalidStmt, "'" + statementType + "' is used outside a function."