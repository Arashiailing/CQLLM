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

from Stmt loopStmt, StmtList loopBody, StmtList elseClause, string loopType  // Variables representing loop components
where
  // Identify for loops with else clauses
  (exists(For forLoop | 
      forLoop = loopStmt and 
      elseClause = forLoop.getOrelse() and 
      loopBody = forLoop.getBody() and 
      loopType = "for"
    )
    or
    // Identify while loops with else clauses
    exists(While whileLoop | 
      whileLoop = loopStmt and 
      elseClause = whileLoop.getOrelse() and 
      loopBody = whileLoop.getBody() and 
      loopType = "while"
    )
  ) and
  // Confirm absence of break statements in the loop body
  not exists(Break breakStmt | loopBody.contains(breakStmt))
select loopStmt,  // Select the problematic loop statement
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."  // Warning message