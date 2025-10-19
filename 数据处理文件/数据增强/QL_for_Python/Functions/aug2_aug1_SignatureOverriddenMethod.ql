/**
 * @name Signature mismatch in overriding method
 * @description Identifies overriding methods with incompatible parameter counts compared to their parent methods,
 *              which may cause runtime errors due to signature incompatibilities.
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

// Detect overriding methods with parameter count mismatches
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Verify base method isn't directly invoked and no overriding siblings are called
  not exists(baseMethod.getACall()) and
  not exists(FunctionValue otherOverridingMethod |
    otherOverridingMethod.overrides(baseMethod) and
    exists(otherOverridingMethod.getACall())
  ) and
  // Ensure derived method meets standard method criteria
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  // Confirm overriding relationship and parameter incompatibility
  derivedMethod.overrides(baseMethod) and
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"