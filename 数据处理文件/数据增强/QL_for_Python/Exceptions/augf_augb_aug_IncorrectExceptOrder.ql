/**
 * @name Unreachable 'except' block
 * @description Identifies except blocks that can never be executed due to improper ordering.
 *              When a general exception handler (catching a parent exception class) is placed
 *              before a specific exception handler (catching a child exception class), the specific
 *              handler becomes unreachable because the general handler will always catch the exception first.
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

// Extract the exception class referenced by an exception handler
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Identify incorrectly ordered exception handlers where a general handler
// precedes a specific handler in the same try statement
predicate hasInvalidExceptionHandlerOrder(ExceptStmt earlierHandler, ClassValue baseException, 
                                         ExceptStmt laterHandler, ClassValue derivedException) {
  exists(int earlierIdx, int laterIdx, Try tryBlock |
    // Verify handlers belong to same try block
    earlierHandler = tryBlock.getHandler(earlierIdx) and
    laterHandler = tryBlock.getHandler(laterIdx) and
    // Confirm handler ordering (earlier appears before later)
    earlierIdx < laterIdx and
    // Resolve exception types
    baseException = getHandledExceptionClass(earlierHandler) and
    derivedException = getHandledExceptionClass(laterHandler) and
    // Check inheritance relationship (base is superclass of derived)
    baseException = derivedException.getASuperType()
  )
}

// Detect unreachable exception handlers due to incorrect ordering
from ExceptStmt laterHandler, ClassValue derivedException, 
     ExceptStmt earlierHandler, ClassValue baseException
where hasInvalidExceptionHandlerOrder(earlierHandler, baseException, 
                                     laterHandler, derivedException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), earlierHandler, "except block", baseException, baseException.getName()