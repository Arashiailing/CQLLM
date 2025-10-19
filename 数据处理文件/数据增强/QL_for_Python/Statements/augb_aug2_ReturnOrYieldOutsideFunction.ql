/**
 * @name Incorrect usage of 'return' or 'yield' outside function scope
 * @description Detects 'return', 'yield', or 'yield from' statements placed outside function definitions,
 *              which cause SyntaxError during execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify problematic statements and their types
from AstNode statementNode, string statementType
where
  // Determine statement type and validate scope
  (
    // Case 1: Return statement outside function
    statementNode instanceof Return and statementType = "return"
    or
    // Case 2: Yield statement outside function
    statementNode instanceof Yield and statementType = "yield"
    or
    // Case 3: Yield from statement outside function
    statementNode instanceof YieldFrom and statementType = "yield from"
  )
  and
  // Verify statement is not within function scope
  not statementNode.getScope() instanceof Function
// Generate alert with statement and contextual message
select statementNode, "Statement '" + statementType + "' is used outside a function definition."