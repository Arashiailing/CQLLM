/**
 * @name Unnecessary 'else' clause in loop
 * @description Identifies 'for' or 'while' loops containing 'else' clauses that are redundant
 *              because the loop body does not contain any 'break' statements. In Python, loop-else
 *              clauses execute only when the loop completes normally (without encountering a 'break').
 *              If no 'break' is present, the 'else' will always execute, making it functionally
 *              equivalent to code placed after the loop.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python  // Import the Python library for code analysis

from Stmt targetLoop, StmtList loopContent, StmtList elseBranch, string loopKind  // Variables representing loop components
where
  // Identify loops with else clauses (either for or while)
  (exists(For forLoop | 
      targetLoop = forLoop and 
      elseBranch = forLoop.getOrelse() and 
      loopContent = forLoop.getBody() and 
      loopKind = "for"
    )
    or
    exists(While whileLoop | 
      targetLoop = whileLoop and 
      elseBranch = whileLoop.getOrelse() and 
      loopContent = whileLoop.getBody() and 
      loopKind = "while"
    )
  ) and
  // Confirm no break statements exist within the loop body
  not exists(Break breakStmt | loopContent.contains(breakStmt))
select targetLoop,  // Select the problematic loop statement
  "This '" + loopKind + "' statement has a redundant 'else' as no 'break' is present in the body."  // Warning message