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
  // Verify the override relationship exists between child and parent methods
  childMethod.overrides(parentMethod) and
  
  // Focus only on regular instance methods, excluding special methods and constructors
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Filter out cases where the parent method is called directly
  not exists(parentMethod.getACall()) and
  
  // Ensure no other overriding child methods are being called
  not exists(FunctionValue otherChildMethod |
    otherChildMethod.overrides(parentMethod) and
    exists(otherChildMethod.getACall())
  ) and
  
  // Check for parameter count incompatibility between child and parent methods
  (
    // Case 1: Child method requires more parameters than parent method can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"