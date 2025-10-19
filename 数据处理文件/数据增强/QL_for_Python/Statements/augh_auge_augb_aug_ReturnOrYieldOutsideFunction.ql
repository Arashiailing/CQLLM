/**
 * @name Return/Yield Statements Outside Function Scope
 * @description Identifies misplaced 'return', 'yield', or 'yield from' statements 
 *              that are located outside of function definitions, which would result 
 *              in a 'SyntaxError' during execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Query objective: Find specific statements used in global scope
from AstNode misplacedStmt, string statementKind
where 
  // Determine the type of statement being checked
  (
    misplacedStmt instanceof Return and statementKind = "return"
    or
    misplacedStmt instanceof Yield and statementKind = "yield"
    or
    misplacedStmt instanceof YieldFrom and statementKind = "yield from"
  ) and
  // Verify that the statement is not within any function's scope
  not exists(Function enclosingFunction | 
    misplacedStmt.getScope() = enclosingFunction.getScope()
  )
// Output results: Violating statements and their error descriptions
select misplacedStmt, "'" + statementKind + "' is used outside a function."