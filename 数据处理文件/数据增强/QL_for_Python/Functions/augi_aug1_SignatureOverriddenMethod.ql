/**
 * @name Signature mismatch in overriding method
 * @description Detects overriding methods with incompatible parameter counts,
 *              which may cause runtime errors due to signature mismatches.
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
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Ensure base method isn't directly called and no sibling overrides are called
  not exists(baseMethod.getACall()) and
  not exists(FunctionValue siblingDerivedMethod |
    siblingDerivedMethod.overrides(baseMethod) and
    exists(siblingDerivedMethod.getACall())
  ) and
  // Validate derived method characteristics
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  // Verify override relationship and parameter incompatibility
  derivedMethod.overrides(baseMethod) and
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"