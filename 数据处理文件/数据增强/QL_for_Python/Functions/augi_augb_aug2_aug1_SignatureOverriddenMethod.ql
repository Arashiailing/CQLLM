/**
 * @name Method Override Signature Mismatch
 * @description Identifies methods that override parent methods but have incompatible parameter counts,
 *              potentially causing runtime errors due to signature incompatibilities.
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

// Identify overriding methods with parameter count incompatibilities
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Verify base method is never directly invoked and no sibling overrides are called
  not exists(baseMethod.getACall()) and
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(baseMethod) and exists(siblingOverride.getACall())
  ) and
  // Validate derived method characteristics
  derivedMethod.isNormalMethod() and
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  // Confirm overriding relationship exists
  derivedMethod.overrides(baseMethod) and
  // Check for parameter count incompatibility
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"