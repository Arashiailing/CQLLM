/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override parent methods with incompatible parameter counts,
 *              potentially causing runtime errors due to signature discrepancies.
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

// Identify overriding methods with parameter signature mismatches
from FunctionValue overriddenMethod, PythonFunctionValue overridingMethod
where
  // Verify override relationship exists
  overridingMethod.overrides(overriddenMethod) and
  // Validate overriding method characteristics
  not overridingMethod.getScope().isSpecialMethod() and
  overridingMethod.getName() != "__init__" and
  overridingMethod.isNormalMethod() and
  // Check parameter count incompatibility
  (
    overridingMethod.minParameters() > overriddenMethod.maxParameters() or
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  ) and
  // Ensure parent method isn't directly invoked
  not exists(overriddenMethod.getACall()) and
  // Confirm no sibling overriding methods are called
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(overriddenMethod) and
    exists(siblingOverride.getACall())
  )
select overridingMethod, 
  "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",
  overriddenMethod, "overridden method"