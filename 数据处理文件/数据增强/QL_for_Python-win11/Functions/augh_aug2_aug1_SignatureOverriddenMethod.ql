/**
 * @name Signature mismatch in overriding method
 * @description Detects overriding methods with incompatible parameter counts relative to their parent methods,
 *              potentially leading to runtime errors due to signature mismatches.
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
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Ensure parent method has no direct invocations and no overriding siblings are called
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue siblingOverridingMethod |
    siblingOverridingMethod.overrides(parentMethod) and
    exists(siblingOverridingMethod.getACall())
  ) and
  // Validate child method meets standard method criteria
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // Confirm inheritance relationship and parameter incompatibility
  childMethod.overrides(parentMethod) and
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"