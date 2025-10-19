/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override parent methods with incompatible signatures,
 *              potentially causing runtime errors due to parameter count/type discrepancies.
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

// Detect overriding methods with signature mismatches in class hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify child method directly overrides parent method
  childMethod.overrides(parentMethod) and
  // Check parameter count incompatibility (child requires more params than parent supports OR child accepts fewer than parent requires)
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  // Exclude special methods and constructors from analysis
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // Ensure parent method has no invocations
  not exists(parentMethod.getACall()) and
  // Filter cases where other sibling overrides exist and are called (reduces false positives)
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(parentMethod) and
    exists(siblingOverride.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"