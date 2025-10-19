/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that are positioned after more general handlers,
 *              making them unreachable since the general handlers will intercept exceptions first.
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

// Identify unreachable exception handlers due to improper ordering
from ExceptStmt earlierExceptBlock, ClassValue superClassType,
     ExceptStmt laterExceptBlock, ClassValue subClassType
where exists(Try tryBlock, int earlierIndex, int laterIndex |
    // Both handlers belong to the same try statement
    earlierExceptBlock = tryBlock.getHandler(earlierIndex) and
    laterExceptBlock = tryBlock.getHandler(laterIndex) and
    // Earlier handler appears before later handler
    earlierIndex < laterIndex and
    // Retrieve handled exception types
    earlierExceptBlock.getType().pointsTo(superClassType) and
    laterExceptBlock.getType().pointsTo(subClassType) and
    // Earlier handler catches a superclass of the later handler's exception
    superClassType = subClassType.getASuperType()
  )
// Generate alert for unreachable handler
select laterExceptBlock,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  subClassType, subClassType.getName(), earlierExceptBlock, "except block", superClassType, superClassType.getName()