/**
 * @name Unnecessary 'else' clause in loop
 * @description Identifies 'for' or 'while' loops with an unnecessary 'else' clause.
 *              The 'else' clause is redundant when the loop body contains no 'break'
 *              statements, as it will always execute after the loop completes.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python

// Define variables for the loop analysis
from Stmt targetLoop, StmtList loopBody, StmtList elseClause, string loopType
where
  // Identify either a for loop or while loop that has an else clause
  (exists(For l | 
      l = targetLoop and 
      elseClause = l.getOrelse() and 
      loopBody = l.getBody() and 
      loopType = "for")
   or
   exists(While l | 
      l = targetLoop and 
      elseClause = l.getOrelse() and 
      loopBody = l.getBody() and 
      loopType = "while"))
  and
  // Ensure the loop body contains no break statements
  not exists(Break b | loopBody.contains(b))
select targetLoop,
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."