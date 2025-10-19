/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers using non-exception types that cannot catch actual exceptions
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

from ExceptFlowNode exceptHandler,
     Value capturedType,
     ClassValue capturedClass,
     ControlFlowNode typeOrigin,
     string typeDescriptor
where
  // Establish exception handling relationship
  exceptHandler.handledException(capturedType, capturedClass, typeOrigin) and
  (
    // Case 1: Exception type is a class not inheriting from BaseException
    exists(ClassValue illegalExceptionClass | 
      illegalExceptionClass = capturedType and
      not illegalExceptionClass.isLegalExceptionType() and
      not illegalExceptionClass.failedInference(_) and
      typeDescriptor = "class '" + illegalExceptionClass.getName() + "'"
    )
    or
    // Case 2: Exception type is not a class (e.g., instance)
    not capturedType instanceof ClassValue and
    typeDescriptor = "instance of '" + capturedClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOrigin, 
  typeDescriptor