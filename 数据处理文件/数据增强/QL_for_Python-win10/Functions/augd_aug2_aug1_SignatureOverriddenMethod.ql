/**
 * @name Signature mismatch in overriding method
 * @description Detects overriding methods with parameter count incompatibilities relative to their parent methods,
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

// Identify overriding methods with parameter count mismatches
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify overriding relationship exists
  childMethod.overrides(parentMethod) and
  // Ensure child method meets standard criteria
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // Confirm parameter incompatibility
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  // Validate parent method isn't directly invoked
  not exists(parentMethod.getACall()) and
  // Ensure no sibling overriding methods are called
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(parentMethod) and
    exists(siblingOverride.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"