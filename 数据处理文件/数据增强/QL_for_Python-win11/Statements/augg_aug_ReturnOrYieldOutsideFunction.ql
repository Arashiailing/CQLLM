/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return' or 'yield' statements used outside function scope,
 *              which would cause a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Define the query targets: find specific statements outside function scope
from AstNode statement, string statementType
where 
  // Ensure the statement is not within any function's scope
  not exists(Function function | statement.getScope() = function.getScope()) and
  (
    // Match return statements and assign type identifier
    statement instanceof Return and statementType = "return"
    or
    // Match yield statements and assign type identifier
    statement instanceof Yield and statementType = "yield"
    or
    // Match yield from statements and assign type identifier
    statement instanceof YieldFrom and statementType = "yield from"
  )
// Output violating statement nodes with corresponding error messages
select statement, "'" + statementType + "' is used outside a function."