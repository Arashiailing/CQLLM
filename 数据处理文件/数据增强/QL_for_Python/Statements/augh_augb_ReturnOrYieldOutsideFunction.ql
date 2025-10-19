/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return', 'yield', or 'yield from' statements used outside function scope,
 *              which causes runtime 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements (return/yield/yield from) located outside any function scope
from AstNode node, string stmtType
where
  // Verify the node is not within any function's scope
  not node.getScope() instanceof Function
  and
  // Classify statement type based on node kind
  (
    node instanceof Return and stmtType = "return"
    or
    node instanceof Yield and stmtType = "yield"
    or
    node instanceof YieldFrom and stmtType = "yield from"
  )
// Report findings with contextual error message
select node, "'" + stmtType + "' is used outside a function."