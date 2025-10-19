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

from Stmt problematicLoop, StmtList loopBody, StmtList elseClause, string loopType  // Variables representing loop components
where
  // Verify no break statements exist in the loop body
  not exists(Break breakStatement | loopBody.contains(breakStatement)) and
  
  // Identify either for or while loops with else clauses
  (
    // Check for 'for' loops with else clauses
    exists(For forLoop | 
      forLoop = problematicLoop and 
      elseClause = forLoop.getOrelse() and 
      loopBody = forLoop.getBody() and 
      loopType = "for"
    )
    or
    // Check for 'while' loops with else clauses
    exists(While whileLoop | 
      whileLoop = problematicLoop and 
      elseClause = whileLoop.getOrelse() and 
      loopBody = whileLoop.getBody() and 
      loopType = "while"
    )
  )
select problematicLoop,  // The loop statement with redundant else
  "This '" + loopType + "' statement has a redundant 'else' as no 'break' is present in the body."  // Warning message