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

from Stmt loopWithElse, StmtList bodyContent, StmtList elseContent, string loopKind  // Variables representing loop components
where
  // Process both for and while loops with else clauses
  (loopWithElse instanceof For and 
    bodyContent = loopWithElse.(For).getBody() and 
    elseContent = loopWithElse.(For).getOrelse() and 
    loopKind = "for"
  )
  or
  (loopWithElse instanceof While and 
    bodyContent = loopWithElse.(While).getBody() and 
    elseContent = loopWithElse.(While).getOrelse() and 
    loopKind = "while"
  )
  and
  // Verify no break statements exist in the loop body
  not exists(Break breakStmt | bodyContent.contains(breakStmt))
select loopWithElse,  // Select the problematic loop statement
  "This '" + loopKind + "' statement has a redundant 'else' as no 'break' is present in the body."  // Warning message