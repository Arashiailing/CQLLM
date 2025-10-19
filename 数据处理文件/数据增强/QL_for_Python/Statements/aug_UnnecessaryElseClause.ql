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

from Stmt loopStmt, StmtList loopBody, StmtList elseClause, string loopType
where
  // Check if the statement is either a for loop or while loop with an else clause
  (exists(For f | f = loopStmt and elseClause = f.getOrelse() and loopBody = f.getBody() and loopType = "for")
   or
   exists(While w | w = loopStmt and elseClause = w.getOrelse() and loopBody = w.getBody() and loopType = "while"))
  and
  // Verify that no break statement exists within the loop body
  not exists(Break b | loopBody.contains(b))
select loopStmt,
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."