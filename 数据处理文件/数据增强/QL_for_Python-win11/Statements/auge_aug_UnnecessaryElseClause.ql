/**
 * @name Unnecessary 'else' clause in loop
 * @description Detects 'for' or 'while' loops with an 'else' clause that serves no purpose
 *              because the loop body doesn't contain a 'break' statement, rendering the 'else' clause unnecessary.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python

from Stmt loopingStatement, StmtList loopBodyContent, StmtList elseBlock, string loopCategory
where
  // Determine if the statement is a for loop or while loop that includes an else clause
  (exists(For forLoop | 
      forLoop = loopingStatement and 
      elseBlock = forLoop.getOrelse() and 
      loopBodyContent = forLoop.getBody() and 
      loopCategory = "for")
   or
   exists(While whileLoop | 
      whileLoop = loopingStatement and 
      elseBlock = whileLoop.getOrelse() and 
      loopBodyContent = whileLoop.getBody() and 
      loopCategory = "while"))
  and
  // Ensure no break statement exists within the loop body
  not exists(Break breakStmt | loopBodyContent.contains(breakStmt))
select loopingStatement,
  "This '" + loopCategory + "' statement has a redundant 'else' as no 'break' is present in the body."