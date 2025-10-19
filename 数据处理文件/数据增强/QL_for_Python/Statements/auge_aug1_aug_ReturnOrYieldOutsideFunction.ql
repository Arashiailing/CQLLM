/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description This query detects instances where 'return', 'yield', or 'yield from' statements are erroneously placed outside of function definitions, leading to a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify all statement nodes that violate function scope rules and their types
from AstNode stmtNode, string stmtType
where 
  // Verify the statement is not within any function scope
  not exists(Function funcDef | stmtNode.getScope() = funcDef.getScope()) and
  (
    // Detect return statements
    stmtNode instanceof Return and stmtType = "return"
    or
    // Detect yield statements
    stmtNode instanceof Yield and stmtType = "yield"
    or
    // Detect yield from statements
    stmtNode instanceof YieldFrom and stmtType = "yield from"
  )
// Output results: violating statement nodes with corresponding error messages
select stmtNode, "'" + stmtType + "' is used outside a function."