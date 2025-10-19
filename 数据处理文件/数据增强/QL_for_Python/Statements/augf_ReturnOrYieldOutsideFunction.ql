/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return'/'yield' statements outside function scope, which cause runtime SyntaxError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify AST nodes and their corresponding statement types
from AstNode astNode, string stmtType
where
  // Verify the node is not within any function's scope
  not astNode.getScope() instanceof Function
  and (
    // Match return statements with "return" type
    astNode instanceof Return and stmtType = "return"
    or
    // Match yield statements with "yield" type
    astNode instanceof Yield and stmtType = "yield"
    or
    // Match yield-from statements with "yield from" type
    astNode instanceof YieldFrom and stmtType = "yield from"
  )
// Generate alert with problematic node and context message
select astNode, "'" + stmtType + "' is used outside a function."