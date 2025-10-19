/**
 * @name Invalid exception type in handler
 * @description Detects exception handling blocks that use non-exception types,
 *              making them incapable of catching actual exceptions when raised.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Analyze exception handling constructs to identify ineffective handlers
from ExceptFlowNode exceptionBlock, Value handledType, ClassValue baseType, 
     ControlFlowNode originNode, string typeDescription
where
  // Verify the exception block handles a specific type from the origin
  exceptionBlock.handledException(handledType, baseType, originNode) and
  // Check for invalid exception types in two scenarios
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = handledType and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      typeDescription = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class value at all
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + baseType.getName() + "'"
  )
select exceptionBlock.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, typeDescription