/**
 * @name Non-exception type in 'except' clause
 * @description Detects exception handlers that use non-exception types which are incapable of catching actual exceptions
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

from ExceptFlowNode handlerNode,
     Value caughtType,
     ClassValue typeClass,
     ControlFlowNode originNode,
     string typeDescription
where
  // Link the exception handler with the type it's attempting to catch
  handlerNode.handledException(caughtType, typeClass, originNode) and
  (
    // Scenario 1: Exception type is a class that doesn't inherit from BaseException
    exists(ClassValue illegalExceptionClass | 
      illegalExceptionClass = caughtType and
      not illegalExceptionClass.isLegalExceptionType() and
      not illegalExceptionClass.failedInference(_) and
      typeDescription = "class '" + illegalExceptionClass.getName() + "'"
    )
    or
    // Scenario 2: Exception type is not a class (e.g., an instance)
    not caughtType instanceof ClassValue and
    typeDescription = "instance of '" + typeClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, 
  typeDescription