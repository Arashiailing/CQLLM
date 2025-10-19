/**
 * @name Unnecessary 'else' clause in loop
 * @description Identifies 'for' or 'while' loops containing an 'else' clause that serves no purpose
 *              since the loop body lacks a 'break' statement, making the 'else' clause redundant.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python

from Stmt loopStmt, StmtList bodyContent, StmtList elseClause, string loopType
where
  // Identify for or while loops with an else clause
  (exists(For forLoop | 
      loopStmt = forLoop and 
      elseClause = forLoop.getOrelse() and 
      bodyContent = forLoop.getBody() and 
      loopType = "for")
   or
   exists(While whileLoop | 
      loopStmt = whileLoop and 
      elseClause = whileLoop.getOrelse() and 
      bodyContent = whileLoop.getBody() and 
      loopType = "while"))
  and
  // Ensure the loop body contains no break statements
  not exists(Break breakStatement | bodyContent.contains(breakStatement))
select loopStmt,
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."