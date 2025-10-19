/**
 * @name Unnecessary 'else' clause in loop
 * @description Identifies 'for' or 'while' loops containing an 'else' clause that never serves its purpose
 *              because the loop body lacks a 'break' statement, making the 'else' clause redundant.
 *              In Python, the else clause of a loop executes only if the loop completes normally
 *              (without encountering a break statement). If there's no break in the loop body,
 *              the else clause will always execute, making it redundant.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python

from Stmt loopStmt, StmtList loopBody, StmtList elseClause, string loopType
where
  // Identify for loops with an else clause
  (exists(For forLoop | 
      loopStmt = forLoop and 
      loopBody = forLoop.getBody() and 
      elseClause = forLoop.getOrelse() and 
      loopType = "for")
   // Identify while loops with an else clause
   or
   exists(While whileLoop | 
      loopStmt = whileLoop and 
      loopBody = whileLoop.getBody() and 
      elseClause = whileLoop.getOrelse() and 
      loopType = "while"))
  and
  // Ensure no break statements exist in the loop body
  not exists(Break breakStmt | loopBody.contains(breakStmt))
select loopStmt,
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."