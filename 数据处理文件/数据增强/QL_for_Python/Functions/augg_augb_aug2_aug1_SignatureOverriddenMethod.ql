/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override parent methods but have incompatible parameter counts,
 *              which may cause runtime errors due to signature incompatibilities.
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

// Find pairs of base methods and their overriding derived methods with parameter count mismatches
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Base method is never directly invoked
  not exists(baseMethod.getACall()) and
  // No sibling methods that override the base method are called
  not exists(FunctionValue siblingOverrideMethod |
    siblingOverrideMethod.overrides(baseMethod) and
    exists(siblingOverrideMethod.getACall())
  ) and
  // Derived method is a normal method (not special or __init__)
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  // Derived method overrides base method
  derivedMethod.overrides(baseMethod) and
  // Parameter count incompatibility between derived and base methods
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"