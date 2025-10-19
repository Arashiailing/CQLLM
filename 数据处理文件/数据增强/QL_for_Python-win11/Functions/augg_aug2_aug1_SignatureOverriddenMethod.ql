/**
 * @name Signature mismatch in overriding method
 * @description Detects overriding methods where parameter count incompatibility exists compared to parent methods,
 *              potentially causing runtime errors due to signature mismatches during method resolution.
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
  // Validate parent method isn't directly invoked and no sibling overrides are called
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  ) and
  // Verify child method meets standard method criteria
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // Confirm overriding relationship and parameter incompatibility
  childMethod.overrides(parentMethod) and
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"