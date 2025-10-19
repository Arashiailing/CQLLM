/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override parent methods but have incompatible parameter counts,
 *              which can lead to runtime errors during method resolution due to signature mismatches.
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

// Find method overrides with signature incompatibilities
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Ensure the base method is not directly invoked and no sibling overrides are called
  not exists(baseMethod.getACall()) and
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(baseMethod) and
    exists(siblingOverride.getACall())
  ) and
  // Validate that the derived method is a normal method (not special or __init__)
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  // Verify the overriding relationship exists
  derivedMethod.overrides(baseMethod) and
  // Check for parameter count incompatibility
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"