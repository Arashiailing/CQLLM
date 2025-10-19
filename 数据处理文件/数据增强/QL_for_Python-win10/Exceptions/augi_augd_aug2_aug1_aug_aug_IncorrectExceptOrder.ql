/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that cannot be executed due to handler ordering,
 *              where a general exception handler earlier in the try-except chain
 *              catches all exceptions before more specific handlers are reached.
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

// Resolves the exception class targeted by an except clause
ClassValue getExceptionClass(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Checks if a later exception handler is shadowed by an earlier broader handler
predicate isShadowedHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                            ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try tryStatement |
    // Both handlers belong to the same try block
    earlierHandler = tryStatement.getHandler(earlierIndex) and
    laterHandler = tryStatement.getHandler(laterIndex) and
    // Earlier handler precedes later handler in source order
    earlierIndex < laterIndex and
    // Resolve exception types for both handlers
    broaderException = getExceptionClass(earlierHandler) and
    narrowerException = getExceptionClass(laterHandler) and
    // Earlier handler catches a superclass of the later handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Identifies all shadowed (unreachable) exception handlers
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
where isShadowedHandler(earlierHandler, broaderException, laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()