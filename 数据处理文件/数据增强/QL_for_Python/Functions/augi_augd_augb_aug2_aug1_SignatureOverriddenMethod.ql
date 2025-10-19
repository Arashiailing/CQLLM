/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override parent methods with incompatible parameter counts,
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

// Detect overriding methods with parameter count mismatches
from FunctionValue overriddenMethod, PythonFunctionValue overridingMethod
where
  // Verify the overridden method is never directly invoked
  not exists(overriddenMethod.getACall()) and
  // Ensure no sibling overriding methods are invoked
  not exists(FunctionValue siblingOverridingMethod |
    siblingOverridingMethod.overrides(overriddenMethod) and
    exists(siblingOverridingMethod.getACall())
  ) and
  // Validate the overriding method meets standard criteria
  overridingMethod.isNormalMethod() and
  not overridingMethod.getScope().isSpecialMethod() and
  overridingMethod.getName() != "__init__" and
  // Confirm the overriding relationship exists
  overridingMethod.overrides(overriddenMethod) and
  // Check for parameter count incompatibility
  (
    overridingMethod.minParameters() > overriddenMethod.maxParameters() or
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  )
select overridingMethod, "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",
  overriddenMethod, "overridden method"