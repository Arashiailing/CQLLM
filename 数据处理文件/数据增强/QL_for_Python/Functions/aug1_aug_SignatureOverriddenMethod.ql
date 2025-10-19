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
  // Core override relationship verification
  childMethod.overrides(parentMethod) and
  
  // Exclude special methods and constructors from analysis
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Focus only on regular instance methods
  childMethod.isNormalMethod() and
  
  // Parameter count incompatibility check
  (
    // Case 1: Child method requires more parameters than parent provides
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent requires
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  
  // Filter out cases where parent method is called
  not exists(parentMethod.getACall()) and
  
  // Ensure no other overriding subclass methods are being called
  not exists(FunctionValue otherChildMethod |
    otherChildMethod.overrides(parentMethod) and
    exists(otherChildMethod.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"