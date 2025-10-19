/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description Detects 'return', 'yield', or 'yield from' statements that are placed outside of any function definition, which would cause a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify all problematic statements and their types
from AstNode problematicStmt, string stmtType
where 
  // First, verify the statement is not within any function's scope
  not exists(Function funcDef | problematicStmt.getScope() = funcDef.getScope()) and
  (
    // Check for return statements
    problematicStmt instanceof Return and stmtType = "return"
    or
    // Check for yield statements
    problematicStmt instanceof Yield and stmtType = "yield"
    or
    // Check for yield from statements
    problematicStmt instanceof YieldFrom and stmtType = "yield from"
  )
// Report the problematic statement with an appropriate error message
select problematicStmt, "'" + stmtType + "' is used outside a function."