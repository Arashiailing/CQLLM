/**
 * @name Unreachable 'except' block
 * @description A specific exception handler placed after a general one becomes unreachable
 *              due to Python's exception handling mechanism.
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

/**
 * Identifies misordered exception handlers where a general exception precedes
 * a specific one, rendering the specific handler unreachable.
 * @param earlierHandler - The first exception handler in sequence
 * @param broaderException - The broader exception class handled first
 * @param laterHandler - The subsequent exception handler in sequence
 * @param specificException - The more specific exception class handled later
 */
predicate detectMalformedExceptOrder(ExceptStmt earlierHandler, ClassValue broaderException, 
                                    ExceptStmt laterHandler, ClassValue specificException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Both handlers must belong to the same try block
    earlierHandler = tryBlock.getHandler(earlierIndex) and
    laterHandler = tryBlock.getHandler(laterIndex) and
    // Verify handler sequence order
    earlierIndex < laterIndex and
    // Extract exception types directly from handlers
    earlierHandler.getType().pointsTo(broaderException) and
    laterHandler.getType().pointsTo(specificException) and
    // Confirm inheritance: broader exception is a superclass
    broaderException = specificException.getASuperType()
  )
}

// Main query detecting all unreachable exception handlers
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue broaderException
where detectMalformedExceptOrder(earlierHandler, broaderException, 
                                laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()