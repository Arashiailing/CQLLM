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

// Identify unreachable exception handlers due to improper handler ordering
from ExceptStmt generalExcept, ClassValue superType, 
     ExceptStmt specificExcept, ClassValue subType
where 
  // Both exception handlers belong to the same try statement
  exists(Try tryBlock, int generalPos, int specificPos |
    generalExcept = tryBlock.getHandler(generalPos) and
    specificExcept = tryBlock.getHandler(specificPos) and
    // General handler precedes specific handler in the sequence
    generalPos < specificPos
  ) and
  // Resolve exception types handled by each clause
  generalExcept.getType().pointsTo(superType) and
  specificExcept.getType().pointsTo(subType) and
  // General handler catches a superclass of specific handler's exception
  superType = subType.getASuperType()
// Report the unreachable specific exception handler
select specificExcept,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  subType, subType.getName(), generalExcept, "except block", superType, superType.getName()