/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects misplaced 'return', 'yield', or 'yield from' statements
 *              that appear outside function definitions, which would cause
 *              'SyntaxError' when executing Python code.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements that are incorrectly positioned outside function contexts
from AstNode outOfFuncStmt, string statementKind
where 
  // Verify the statement is not nested within any function's scope
  not exists(Function enclosingFunc | 
    outOfFuncStmt.getScope() = enclosingFunc.getScope()
  )
  and
  // Classify the type of invalid statement based on its AST node type
  (
    outOfFuncStmt instanceof Return and statementKind = "return"
    or
    outOfFuncStmt instanceof Yield and statementKind = "yield"
    or
    outOfFuncStmt instanceof YieldFrom and statementKind = "yield from"
  )
// Report the problematic statement with an appropriate error message
select outOfFuncStmt, "'" + statementKind + "' is used outside a function."