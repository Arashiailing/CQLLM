/**
 * @name Unnecessary 'else' clause in loop
 * @description Detects 'for' or 'while' loops that contain an 'else' clause which serves no purpose
 *              because the loop body doesn't contain any 'break' statement, rendering the 'else' clause
 *              functionally redundant.
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
from Stmt currentLoop, StmtList loopContent, StmtList elseBlock, string loopKind
where
  // Identify either a for loop or while loop that has an else clause
  (exists(For f | 
      f = currentLoop and 
      elseBlock = f.getOrelse() and 
      loopContent = f.getBody() and 
      loopKind = "for")
   or
   exists(While w | 
      w = currentLoop and 
      elseBlock = w.getOrelse() and 
      loopContent = w.getBody() and 
      loopKind = "while"))
  and
  // Ensure the loop body contains no break statements
  not exists(Break b | loopContent.contains(b))
select currentLoop,
  "This '" + loopKind + "' statement has a redundant 'else' as no 'break' is present in the body."