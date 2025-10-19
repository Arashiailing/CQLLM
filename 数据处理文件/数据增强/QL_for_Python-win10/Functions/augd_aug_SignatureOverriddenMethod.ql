/**
 * @name Signature mismatch in overriding method
 * @description Detects when a subclass method overrides a superclass method
 *              with incompatible parameter counts, potentially causing runtime errors.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python
import Expressions.CallArgs

// Identify methods with signature mismatches in inheritance hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // First, verify the override relationship and method types
  childMethod.overrides(parentMethod) and
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Then, check for parameter count incompatibility
  (
    // Case 1: Child method requires more parameters than parent method provides
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  
  // Finally, filter out cases where methods are being called
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue otherChildMethod |
    otherChildMethod.overrides(parentMethod) and
    exists(otherChildMethod.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"