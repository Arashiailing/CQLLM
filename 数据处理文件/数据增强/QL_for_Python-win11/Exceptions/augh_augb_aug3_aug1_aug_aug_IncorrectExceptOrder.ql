/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are never executed due to incorrect ordering,
 *              where a broader exception handler precedes a more specific one, catching all exceptions first.
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

// Query to detect exception handling blocks that become unreachable
// due to improper ordering of exception types
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
where exists(int earlierIndex, int laterIndex, Try parentTry |
  // Verify both handlers are part of the same try statement
  earlierHandler = parentTry.getHandler(earlierIndex) and
  laterHandler = parentTry.getHandler(laterIndex) and
  
  // Ensure source code position: broader handler comes first
  earlierIndex < laterIndex and
  
  // Determine the exception types handled by each clause
  earlierHandler.getType().pointsTo(broaderException) and
  laterHandler.getType().pointsTo(narrowerException) and
  
  // Confirm inheritance relationship that makes the later handler unreachable
  broaderException = narrowerException.getASuperType()
)
// Generate alert with the unreachable block and detailed explanation
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()