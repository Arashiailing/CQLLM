/**
 * @name Signature mismatch in overriding method
 * @description Detects methods in child classes that override parent class methods
 *              with incompatible parameter counts, potentially causing runtime errors.
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

// Identify method overrides where parameter counts don't match
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify method override relationship and exclude special cases
  childMethod.overrides(parentMethod) and
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Check for parameter count incompatibility between parent and child methods
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  
  // Filter out methods that are actually invoked (either directly or through sibling overrides)
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"