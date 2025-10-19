/**
 * @name Unreachable 'except' block
 * @description Identifies situations where a specific exception handler is positioned after a general one,
 *              causing it to be unreachable because the general handler will always intercept the exception first.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// Detects exception handlers that can never be executed due to improper ordering
// where a general exception handler precedes a more specific one
from ExceptStmt earlierHandler, ClassValue broaderExceptionType, 
     ExceptStmt laterHandler, ClassValue specificExceptionType
where 
  // Both handlers must be part of the same try statement
  exists(Try enclosingTry, int earlierIndex, int laterIndex |
    // Establish the relationship between handlers and their positions
    earlierHandler = enclosingTry.getHandler(earlierIndex) and
    laterHandler = enclosingTry.getHandler(laterIndex) and
    // Ensure the general handler comes before the specific one
    earlierIndex < laterIndex and
    // Extract the exception types handled by each handler
    earlierHandler.getType().pointsTo(broaderExceptionType) and
    laterHandler.getType().pointsTo(specificExceptionType) and
    // Verify that the earlier handler catches a superclass of the later handler's exception
    broaderExceptionType = specificExceptionType.getASuperType()
  )
// Report the unreachable handler with detailed explanation
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), earlierHandler, "except block", broaderExceptionType, broaderExceptionType.getName()