/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers using non-exception types, rendering them ineffective for catching actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except */

import python

from ExceptFlowNode exceptNode,
     Value caughtType,
     ClassValue caughtClass,
     ControlFlowNode typeOrigin,
     string typeDesc
where
  // Establish exception handling context
  exceptNode.handledException(caughtType, caughtClass, typeOrigin) and
  (
    // Case 1: Exception type is a class not inheriting from BaseException
    exists(ClassValue invalidClass |
      invalidClass = caughtType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDesc = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Exception type is a non-class (e.g., instance)
    exists( | 
      not caughtType instanceof ClassValue and
      typeDesc = "instance of '" + caughtClass.getName() + "'"
    )
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.",
  typeOrigin,
  typeDesc