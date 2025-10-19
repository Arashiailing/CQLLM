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

// Detects unreachable exception handlers caused by improper ordering in try-except blocks
from ExceptStmt generalHandler, ClassValue parentType, 
     ExceptStmt specificHandler, ClassValue childType
where 
  // Both handlers belong to the same try statement
  exists(Try tryBlock, int generalIdx, int specificIdx |
    generalHandler = tryBlock.getHandler(generalIdx) and
    specificHandler = tryBlock.getHandler(specificIdx) and
    // General handler appears before specific handler
    generalIdx < specificIdx
  ) and
  // Resolve exception types handled by each clause
  generalHandler.getType().pointsTo(parentType) and
  specificHandler.getType().pointsTo(childType) and
  // General handler catches a superclass of specific handler's exception
  parentType = childType.getASuperType()
// Report the unreachable specific exception handler
select specificHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  childType, childType.getName(), generalHandler, "except block", parentType, parentType.getName()