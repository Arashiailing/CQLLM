/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override parent methods but have incompatible parameter counts,
 *              which may cause runtime errors when polymorphism is used.
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

// Find overriding methods with parameter count incompatibilities
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Establish inheritance relationship
  derivedMethod.overrides(baseMethod) and
  
  // Filter derived method characteristics
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  
  // Check parameter count mismatch conditions
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  ) and
  
  // Verify base method is not directly invoked
  not exists(baseMethod.getACall()) and
  
  // Ensure no sibling overriding methods are called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and
    exists(siblingMethod.getACall())
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"