/**
 * @name Signature mismatch in overriding method
 * @description Detects overriding methods where parameter counts are incompatible with their parent methods,
 *              potentially causing runtime errors due to signature mismatches.
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

// Identify overriding methods with incompatible parameter counts
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify parent method is never directly invoked
  not exists(parentMethod.getACall()) and
  // Ensure no sibling overriding methods are called
  not exists(FunctionValue siblingOverridingMethod |
    siblingOverridingMethod.overrides(parentMethod) and
    exists(siblingOverridingMethod.getACall())
  ) and
  // Validate child method characteristics
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // Confirm overriding relationship exists
  childMethod.overrides(parentMethod) and
  // Check parameter count incompatibility
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"