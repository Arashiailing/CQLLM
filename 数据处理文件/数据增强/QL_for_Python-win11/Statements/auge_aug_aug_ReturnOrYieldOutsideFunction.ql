/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects when 'return', 'yield', or 'yield from' statements are used outside function scope,
 *              which would cause a 'SyntaxError' at runtime in Python.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements that are incorrectly placed outside function scope
from AstNode misplacedStatement, string statementType
where 
  // Verify the statement is not within any function's scope
  not exists(Function containingFunction | 
    misplacedStatement.getScope() = containingFunction.getScope()
  ) and
  // Check for different types of invalid statements
  (
    misplacedStatement instanceof Return and statementType = "return"
    or
    misplacedStatement instanceof Yield and statementType = "yield"
    or
    misplacedStatement instanceof YieldFrom and statementType = "yield from"
  )
// Report the problematic statement with appropriate error message
select misplacedStatement, "'" + statementType + "' is used outside a function."