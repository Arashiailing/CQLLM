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
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Core override relationship verification
  derivedMethod.overrides(baseMethod) and
  
  // Exclude special methods and constructors from analysis
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Focus only on regular instance methods
  derivedMethod.isNormalMethod() and
  
  // Parameter count incompatibility check
  exists(
    int baseMin, int baseMax, int derivedMin, int derivedMax |
    baseMin = baseMethod.minParameters() and
    baseMax = baseMethod.maxParameters() and
    derivedMin = derivedMethod.minParameters() and
    derivedMax = derivedMethod.maxParameters() and
    (
      // Case 1: Derived method requires more parameters than base provides
      derivedMin > baseMax
      or
      // Case 2: Derived method accepts fewer parameters than base requires
      derivedMax < baseMin
    )
  ) and
  
  // Filter out cases where base method is called
  not exists(baseMethod.getACall()) and
  
  // Ensure no other overriding subclass methods are being called
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(baseMethod) and
    exists(otherDerivedMethod.getACall())
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"