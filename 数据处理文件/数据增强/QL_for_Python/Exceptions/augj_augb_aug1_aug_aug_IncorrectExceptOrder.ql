/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute due to being positioned
 *              after a more general handler that intercepts exceptions first.
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

// Extracts the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Identifies when an except handler becomes unreachable due to handler ordering
predicate hasUnreachableExceptionHandler(ExceptStmt precedingExcept, ClassValue broaderType, 
                                        ExceptStmt succeedingExcept, ClassValue narrowerType) {
  exists(int precedingIndex, int succeedingIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    precedingExcept = tryBlock.getHandler(precedingIndex) and
    succeedingExcept = tryBlock.getHandler(succeedingIndex) and
    // Preceding handler appears before succeeding handler in source order
    precedingIndex < succeedingIndex and
    // Extract exception types for both handlers
    broaderType = getHandledExceptionType(precedingExcept) and
    narrowerType = getHandledExceptionType(succeedingExcept) and
    // Preceding handler catches a superclass of the succeeding handler's exception
    broaderType = narrowerType.getASuperType()
  )
}

// Main query identifying all unreachable exception handlers
from ExceptStmt precedingExcept, ClassValue broaderType, 
     ExceptStmt succeedingExcept, ClassValue narrowerType
where hasUnreachableExceptionHandler(precedingExcept, broaderType, succeedingExcept, narrowerType)
select succeedingExcept,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerType, narrowerType.getName(), precedingExcept, "except block", broaderType, broaderType.getName()