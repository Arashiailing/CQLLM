/**
 * @name Unreachable 'except' block
 * @description Identifies unreachable exception handlers in Python code where a general exception
 *              handler (parent class) precedes a specific exception handler (child class),
 *              making the specific handler unreachable as the general one catches all exceptions first.
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
ClassValue getExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Detects improper exception handler ordering where a general exception handler
// appears before a more specific exception handler within the same try statement
predicate hasIncorrectExceptOrder(ExceptStmt generalExceptionHandler, ClassValue generalExceptionType, 
                                 ExceptStmt specificExceptionHandler, ClassValue specificExceptionType) {
  exists(int generalHandlerIndex, int specificHandlerIndex, Try tryStmt |
    // Both handlers are part of the same try statement
    generalExceptionHandler = tryStmt.getHandler(generalHandlerIndex) and
    specificExceptionHandler = tryStmt.getHandler(specificHandlerIndex) and
    // Verify the handler order (general handler comes first)
    generalHandlerIndex < specificHandlerIndex and
    // Obtain the exception types for both handlers
    generalExceptionType = getExceptionClass(generalExceptionHandler) and
    specificExceptionType = getExceptionClass(specificExceptionHandler) and
    // Check inheritance relationship (general exception is a supertype of specific exception)
    generalExceptionType = specificExceptionType.getASuperType()
  )
}

// Locate all unreachable exception handlers due to incorrect ordering
from ExceptStmt specificExceptionHandler, ClassValue specificExceptionType, 
     ExceptStmt generalExceptionHandler, ClassValue generalExceptionType
where hasIncorrectExceptOrder(generalExceptionHandler, generalExceptionType, 
                             specificExceptionHandler, specificExceptionType)
select specificExceptionHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), generalExceptionHandler, "except block", generalExceptionType, generalExceptionType.getName()