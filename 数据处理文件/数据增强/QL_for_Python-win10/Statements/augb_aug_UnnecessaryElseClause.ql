/**
 * @name Unnecessary 'else' clause in loop
 * @description Identifies 'for' or 'while' loops containing an 'else' clause that never serves its purpose
 *              because the loop body lacks a 'break' statement, making the 'else' clause redundant.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python

from Stmt targetLoop, StmtList loopContent, StmtList elseSection, string loopKind
where
  // Identify for loops with an else clause
  (exists(For forStmt | 
      targetLoop = forStmt and 
      loopContent = forStmt.getBody() and 
      elseSection = forStmt.getOrelse() and 
      loopKind = "for")
   // Identify while loops with an else clause
   or
   exists(While whileStmt | 
      targetLoop = whileStmt and 
      loopContent = whileStmt.getBody() and 
      elseSection = whileStmt.getOrelse() and 
      loopKind = "while"))
  and
  // Ensure no break statements exist in the loop body
  not exists(Break breakStatement | loopContent.contains(breakStatement))
select targetLoop,
  "This '" + loopKind + "' statement has a redundant 'else' as no 'break' is present in the body."