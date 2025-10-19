/**
 * @name Unnecessary 'else' clause in loop
 * @description Detects 'for' or 'while' loops with 'else' clauses that are unnecessary because the loop body doesn't contain a 'break' statement.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python  // Import the Python library for code analysis

from Stmt targetLoop, StmtList loopBodyStmts, StmtList elseBlock, string loopKind  // Variables representing loop components
where
  // Confirm absence of break statements in the loop body
  not exists(Break breakStmt | loopBodyStmts.contains(breakStmt)) and
  // Identify loops with else clauses (either for or while)
  (exists(For forLoop | 
      forLoop = targetLoop and 
      elseBlock = forLoop.getOrelse() and 
      loopBodyStmts = forLoop.getBody() and 
      loopKind = "for"
    )
    or
    // Identify while loops with else clauses
    exists(While whileLoop | 
      whileLoop = targetLoop and 
      elseBlock = whileLoop.getOrelse() and 
      loopBodyStmts = whileLoop.getBody() and 
      loopKind = "while"
    )
  )
select targetLoop,  // Select the problematic loop statement
  "This '" + loopKind + "' statement has a redundant 'else' as no 'break' is present in the body."  // Warning message