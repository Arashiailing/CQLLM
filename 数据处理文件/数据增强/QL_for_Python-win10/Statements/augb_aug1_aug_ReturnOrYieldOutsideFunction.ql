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

// Identify all problematic statements that are incorrectly placed outside function definitions
from AstNode problematicStmt, string stmtType
where 
  // First, verify the statement is not within any function's scope
  not exists(Function functionDef | problematicStmt.getScope() = functionDef.getScope()) and
  (
    // Check for return statements used in invalid context
    problematicStmt instanceof Return and stmtType = "return"
    or
    // Check for yield statements used in invalid context
    problematicStmt instanceof Yield and stmtType = "yield"
    or
    // Check for yield from statements used in invalid context
    problematicStmt instanceof YieldFrom and stmtType = "yield from"
  )
// Report the findings with appropriate error message
select problematicStmt, "'" + stmtType + "' is used outside a function."