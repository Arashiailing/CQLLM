/**
 * @name Incorrect usage of 'return' or 'yield' outside function scope
 * @description Identifies misplaced 'return', 'yield', or 'yield from' statements
 *              occurring outside function definitions, which would cause SyntaxError
 *              during Python execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Find statements that are invalid when used outside function contexts
from AstNode illegalStmt, string stmtKind
where
  // Classify the statement type (return/yield/yield from)
  exists(string type |
    (
      illegalStmt instanceof Return and type = "return"
      or
      illegalStmt instanceof Yield and type = "yield"
      or
      illegalStmt instanceof YieldFrom and type = "yield from"
    ) and
    stmtKind = type
  )
  and
  // Ensure the statement is not nested within any function scope
  not exists(Function func | illegalStmt.getScope() = func)
// Report the problematic statement with contextual error message
select illegalStmt, "Statement '" + stmtKind + "' is used outside a function definition."