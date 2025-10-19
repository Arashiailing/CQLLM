/**
 * @name Method Override Signature Incompatibility
 * @description Identifies child methods that override parent methods but have incompatible parameter counts,
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

// Detect methods with parameter count incompatibilities in inheritance hierarchies
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Establish the overriding relationship between methods
  derivedMethod.overrides(baseMethod) and
  // Validate the derived method meets standard criteria
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  // Ensure base method is never directly invoked
  not exists(baseMethod.getACall()) and
  // Confirm no sibling overrides are called
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(baseMethod) and
    exists(siblingOverride.getACall())
  ) and
  // Check for parameter count incompatibility
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"