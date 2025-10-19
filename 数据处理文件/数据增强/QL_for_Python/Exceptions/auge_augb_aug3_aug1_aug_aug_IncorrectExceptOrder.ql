/**
 * @name Unreachable 'except' block
 * @description Identifies exception handling blocks that can never be executed due to incorrect
 *              sequence, where a base exception handler shadows a more specific one that follows.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// Query to detect exception handlers that are masked by preceding general handlers
from ExceptStmt earlierHandler, ClassValue baseException, 
     ExceptStmt laterHandler, ClassValue derivedException
where 
  // Ensure both handlers are within the same try statement
  exists(int earlierIndex, int laterIndex, Try parentTry |
    earlierHandler = parentTry.getHandler(earlierIndex) and
    laterHandler = parentTry.getHandler(laterIndex) and
    
    // Verify source code ordering: earlier handler appears before later one
    earlierIndex < laterIndex
  ) and
  
  // Extract the exception types associated with each handler
  earlierHandler.getType().pointsTo(baseException) and
  laterHandler.getType().pointsTo(derivedException) and
  
  // Confirm inheritance relationship that makes the later handler unreachable
  baseException = derivedException.getASuperType()
  
// Output the unreachable block with explanatory message
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), earlierHandler, "except block", baseException, baseException.getName()