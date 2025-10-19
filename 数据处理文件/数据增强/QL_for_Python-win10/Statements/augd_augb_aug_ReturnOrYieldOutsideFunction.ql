/**
 * @name Detection of 'return' or 'yield' statements outside function scope
 * @description Identifies usage of 'return', 'yield', or 'yield from' statements 
 *              outside of function definitions, which leads to runtime 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

/* This query detects problematic statements that are used outside function scope.
   Such statements include 'return', 'yield', and 'yield from', which should only
   appear within function definitions in Python code. */
from AstNode invalidStatement, string statementType
where 
  /* First, identify the type of problematic statement */
  (
    invalidStatement instanceof Return and statementType = "return"
    or
    invalidStatement instanceof Yield and statementType = "yield"
    or
    invalidStatement instanceof YieldFrom and statementType = "yield from"
  )
  and
  /* Then, verify it's not contained within any function scope */
  not exists(Function parentFunction | 
    invalidStatement.getScope() = parentFunction.getScope()
  )
/* Output the problematic statement with an appropriate error message */
select invalidStatement, "'" + statementType + "' is used outside a function."