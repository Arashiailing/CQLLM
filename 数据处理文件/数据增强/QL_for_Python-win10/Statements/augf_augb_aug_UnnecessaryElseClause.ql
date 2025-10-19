/**
 * @name Redundant 'else' clause in loop constructs
 * @description Detects 'for' or 'while' loops that include an 'else' clause which is never executed
 *              due to the absence of 'break' statements within the loop body, rendering the 'else' clause unnecessary.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python

from Stmt loopStatement, StmtList loopBody, StmtList elseClause, string loopType
where
  // Identify loops with an else clause (either for or while)
  (exists(For forLoop | 
      loopStatement = forLoop and 
      loopBody = forLoop.getBody() and 
      elseClause = forLoop.getOrelse() and 
      loopType = "for")
   or
   exists(While whileLoop | 
      loopStatement = whileLoop and 
      loopBody = whileLoop.getBody() and 
      elseClause = whileLoop.getOrelse() and 
      loopType = "while"))
  and
  // Verify no break statements exist in the loop body
  not exists(Break breakStmt | loopBody.contains(breakStmt))
select loopStatement,
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."