/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Identifies instances where 'return', 'yield', or 'yield from' statements
 *              are placed outside of function definitions. Such usage results in a 
 *              'SyntaxError' when the code is executed.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify nodes that are return/yield statements outside any function scope
from AstNode targetNode, string nodeType
where 
  // First, verify the node is not contained within any function's scope
  not exists(Function enclosingFunction | 
    targetNode.getScope() = enclosingFunction.getScope()
  )
  and
  // Then, determine the type of statement and assign corresponding identifier
  (
    targetNode instanceof Return and nodeType = "return"
    or
    targetNode instanceof Yield and nodeType = "yield"
    or
    targetNode instanceof YieldFrom and nodeType = "yield from"
  )
// Report the violating node with an appropriate error message
select targetNode, "'" + nodeType + "' is used outside a function."