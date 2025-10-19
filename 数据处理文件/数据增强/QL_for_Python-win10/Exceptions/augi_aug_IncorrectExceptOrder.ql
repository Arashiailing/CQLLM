/**
 * @name Unreachable 'except' block
 * @description Detects except blocks that are never executed because a more general
 *              exception handler is placed before a more specific one.
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

// Extract the exception class associated with an exception handling block
ClassValue getHandledException(ExceptStmt exceptBlock) { 
  exceptBlock.getType().pointsTo(result) 
}

// Identify problematic exception handler ordering where a superclass exception
// handler precedes a subclass exception handler within the same try statement
predicate exceptOrderingIssue(ExceptStmt priorHandler, ClassValue generalException, 
                             ExceptStmt subsequentHandler, ClassValue preciseException) {
  // Verify both handlers belong to the same try statement
  exists(Try tryBlock, int priorIdx, int subsequentIdx |
    priorHandler = tryBlock.getHandler(priorIdx) and
    subsequentHandler = tryBlock.getHandler(subsequentIdx) and
    priorIdx < subsequentIdx
  ) and
  // Check inheritance relationship between exception types
  generalException = getHandledException(priorHandler) and
  preciseException = getHandledException(subsequentHandler) and
  generalException = preciseException.getASuperType()
}

// Find all unreachable exception handling blocks
from ExceptStmt subsequentHandler, ClassValue preciseException, 
     ExceptStmt priorHandler, ClassValue generalException
where exceptOrderingIssue(priorHandler, generalException, 
                         subsequentHandler, preciseException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  preciseException, preciseException.getName(), priorHandler, "except block", generalException, generalException.getName()