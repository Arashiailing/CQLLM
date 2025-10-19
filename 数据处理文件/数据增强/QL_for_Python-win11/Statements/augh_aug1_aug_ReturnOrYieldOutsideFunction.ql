/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description Detects 'return', 'yield', or 'yield from' statements that are incorrectly placed outside function definitions, which would cause a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements that should only appear inside functions
from AstNode problematicStmt, string stmtType
where 
  // First, ensure the statement is not within any function's scope
  not exists(Function enclosingFunc | problematicStmt.getScope() = enclosingFunc.getScope())
  and
  // Then, check if it's one of the problematic statement types
  (
    problematicStmt instanceof Return and stmtType = "return"
    or
    problematicStmt instanceof Yield and stmtType = "yield"
    or
    problematicStmt instanceof YieldFrom and stmtType = "yield from"
  )
// Report the problematic statement with an appropriate error message
select problematicStmt, "'" + stmtType + "' is used outside a function."