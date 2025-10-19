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

// Identifies unreachable exception handlers due to improper ordering
from ExceptStmt priorHandler, ClassValue superType, 
     ExceptStmt subsequentHandler, ClassValue subType
where exists(Try tryBlock, int priorIndex, int subsequentIndex |
    // Both handlers belong to the same try statement
    priorHandler = tryBlock.getHandler(priorIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // Earlier handler appears before later handler
    priorIndex < subsequentIndex and
    // Retrieve handled exception types
    priorHandler.getType().pointsTo(superType) and
    subsequentHandler.getType().pointsTo(subType) and
    // Earlier handler catches a superclass of the later handler's exception
    superType = subType.getASuperType()
  )
// Generate alert for unreachable handler
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  subType, subType.getName(), priorHandler, "except block", superType, superType.getName()