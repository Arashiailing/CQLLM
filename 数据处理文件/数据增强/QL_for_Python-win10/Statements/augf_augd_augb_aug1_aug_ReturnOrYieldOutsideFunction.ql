/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description Detects misplaced 'return', 'yield', or 'yield from' statements that appear outside function boundaries, which would cause Python to raise a SyntaxError during execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements incorrectly positioned outside function definitions
from AstNode misplacedStmt, string stmtType
where 
  // Verify statement exists outside any function's scope
  not exists(Function enclosingFunc | misplacedStmt.getScope() = enclosingFunc.getScope()) and
  (
    // Capture return statements in invalid contexts
    misplacedStmt instanceof Return and stmtType = "return"
    or
    // Capture yield statements in invalid contexts
    misplacedStmt instanceof Yield and stmtType = "yield"
    or
    // Capture yield from statements in invalid contexts
    misplacedStmt instanceof YieldFrom and stmtType = "yield from"
  )
// Generate alert with descriptive error message
select misplacedStmt, "'" + stmtType + "' is used outside a function."