/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return', 'yield', or 'yield from' statements that appear
 *              outside of function definitions. These statements cause a 'SyntaxError'
 *              at runtime because they are only valid within function contexts.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Find statements (return/yield) that are incorrectly placed outside function boundaries
from AstNode problematicNode, string statementType
where 
  // Check that the node is not within any function's scope
  not exists(Function parentFunction | 
    problematicNode.getScope() = parentFunction.getScope()
  )
  and
  // Classify the problematic statement type
  (
    problematicNode instanceof Return and statementType = "return"
    or
    problematicNode instanceof Yield and statementType = "yield"
    or
    problematicNode instanceof YieldFrom and statementType = "yield from"
  )
// Generate alert with the specific statement type in the error message
select problematicNode, "'" + statementType + "' is used outside a function."