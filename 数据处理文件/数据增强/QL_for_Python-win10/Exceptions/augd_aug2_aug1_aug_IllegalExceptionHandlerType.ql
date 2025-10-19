/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that use non-exception types,
 *              which are ineffective as they never match actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Core variables for exception handler analysis
from ExceptFlowNode exceptNode, Value capturedType, ClassValue baseException, 
     ControlFlowNode sourceNode, string typeDescriptor
where
  // Ensure handler processes a specific exception type from source
  exceptNode.handledException(capturedType, baseException, sourceNode) and
  (
    // Case 1: Invalid exception class type
    exists(ClassValue invalidClass | 
      invalidClass = capturedType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescriptor = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Non-class exception type
    not capturedType instanceof ClassValue and
    typeDescriptor = "instance of '" + baseException.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeDescriptor