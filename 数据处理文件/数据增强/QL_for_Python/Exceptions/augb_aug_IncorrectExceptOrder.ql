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

// Extract the exception class associated with an exception handler
ClassValue extractExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Detect incorrect ordering of exception handlers where a general exception
// handler precedes a more specific one in the same try statement
predicate detectIncorrectExceptionHandlerOrder(ExceptStmt precedingHandler, ClassValue generalException, 
                                              ExceptStmt subsequentHandler, ClassValue particularException) {
  exists(int precedingIndex, int subsequentIndex, Try tryBlock |
    // Ensure both handlers belong to the same try statement
    precedingHandler = tryBlock.getHandler(precedingIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // Verify the order of handlers (preceding comes before subsequent)
    precedingIndex < subsequentIndex and
    // Extract the exception types
    generalException = extractExceptionClass(precedingHandler) and
    particularException = extractExceptionClass(subsequentHandler) and
    // Check inheritance relationship (general exception is a superclass of the specific one)
    generalException = particularException.getASuperType()
  )
}

// Find all unreachable exception handlers due to incorrect ordering
from ExceptStmt subsequentHandler, ClassValue particularException, 
     ExceptStmt precedingHandler, ClassValue generalException
where detectIncorrectExceptionHandlerOrder(precedingHandler, generalException, 
                                         subsequentHandler, particularException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  particularException, particularException.getName(), precedingHandler, "except block", generalException, generalException.getName()