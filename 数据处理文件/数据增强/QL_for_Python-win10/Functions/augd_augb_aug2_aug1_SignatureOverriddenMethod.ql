/**
 * @name Signature mismatch in overriding method
 * @description Detects when a method overrides a parent method but has an incompatible number of parameters,
 *              which can lead to runtime errors due to signature incompatibilities.
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
from FunctionValue parentFunc, PythonFunctionValue childFunc
where
  // Verify parent method is never directly invoked
  not exists(parentFunc.getACall()) and
  // Ensure no sibling overriding methods are called
  not exists(FunctionValue siblingFunc |
    siblingFunc.overrides(parentFunc) and
    exists(siblingFunc.getACall())
  ) and
  // Validate child method meets standard method criteria
  not childFunc.getScope().isSpecialMethod() and
  childFunc.getName() != "__init__" and
  childFunc.isNormalMethod() and
  // Confirm overriding relationship exists
  childFunc.overrides(parentFunc) and
  // Check for parameter count incompatibility
  (
    childFunc.minParameters() > parentFunc.maxParameters() or
    childFunc.maxParameters() < parentFunc.minParameters()
  )
select childFunc, "Overriding method '" + childFunc.getName() + "' has signature mismatch with $@.",
  parentFunc, "overridden method"