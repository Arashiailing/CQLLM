/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers specifying non-exception types that will never catch exceptions.
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

// Identify non-exception types used in exception handlers
from ExceptFlowNode exceptHandler, Value handledType, ClassValue typeClass, 
     ControlFlowNode originNode, string description
where
  // Analyze exception types handled by the except clause
  exceptHandler.handledException(handledType, typeClass, originNode) and
  (
    // Case 1: Type is a class but not a valid exception class
    exists(ClassValue illegalClass | 
      illegalClass = handledType and
      not illegalClass.isLegalExceptionType() and
      not illegalClass.failedInference(_) and
      description = "class '" + illegalClass.getName() + "'"
    )
    or
    // Case 2: Type is a class instance instead of a class
    not handledType instanceof ClassValue and
    description = "instance of '" + typeClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, description