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

// Identify statements illegally positioned outside function boundaries
from AstNode offendingNode, string statementType
where 
  // Verify statement exists outside any function's lexical scope
  not exists(Function enclosingFunction | 
    offendingNode.getScope() = enclosingFunction.getScope()
  ) and
  // Classify the invalid statement type
  (
    // Handle return statement misuse
    offendingNode instanceof Return and statementType = "return"
    or
    // Handle yield statement misuse
    offendingNode instanceof Yield and statementType = "yield"
    or
    // Handle yield from statement misuse
    offendingNode instanceof YieldFrom and statementType = "yield from"
  )
// Report violation with contextual error message
select offendingNode, "'" + statementType + "' is used outside a function."