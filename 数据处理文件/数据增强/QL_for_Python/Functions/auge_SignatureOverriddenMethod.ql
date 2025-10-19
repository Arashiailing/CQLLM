/**
 * @name Signature mismatch in overriding method
 * @description Detects when a method override has incompatible parameter counts
 *              compared to its base method, which may cause runtime errors.
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

from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Validate derived method characteristics
  derivedMethod.isNormalMethod() and
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Verify override relationship
  derivedMethod.overrides(baseMethod) and
  
  // Check parameter count incompatibility
  (
    derivedMethod.minParameters() > baseMethod.maxParameters()
    or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  ) and
  
  // Ensure no calls exist to base method
  not exists(baseMethod.getACall()) and
  
  // Verify no other overriding methods are called
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(baseMethod) and
    exists(otherDerivedMethod.getACall())
  )
select derivedMethod, 
  "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.", 
  baseMethod, 
  "overridden method"