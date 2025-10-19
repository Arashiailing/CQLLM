/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects misplaced 'return', 'yield', or 'yield from' statements
 *              outside function scope, which cause 'SyntaxError' in Python.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Find statements that are incorrectly placed outside function boundaries
from AstNode invalidStatement, string statementKind
where 
  // First, determine the type of statement being analyzed
  (
    invalidStatement instanceof Return and statementKind = "return"
    or
    invalidStatement instanceof Yield and statementKind = "yield"
    or
    invalidStatement instanceof YieldFrom and statementKind = "yield from"
  ) and
  // Then, verify the statement exists outside any function's lexical scope
  not exists(Function parentFunction | 
    invalidStatement.getScope() = parentFunction.getScope()
  )
// Generate a detailed error message for each identified violation
select invalidStatement, "'" + statementKind + "' is used outside a function."