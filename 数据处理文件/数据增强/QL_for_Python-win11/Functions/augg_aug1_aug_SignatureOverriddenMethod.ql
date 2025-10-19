/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods in subclasses that override superclass methods
 *              with incompatible parameter counts, which may lead to runtime errors.
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

// Find method overrides with parameter count inconsistencies
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Override relationship and method type verification
  subclassMethod.overrides(superclassMethod) and
  subclassMethod.isNormalMethod() and
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Parameter count incompatibility scenarios
  (
    subclassMethod.minParameters() > superclassMethod.maxParameters() or
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  ) and
  
  // Invocation filtering
  not exists(superclassMethod.getACall()) and
  not exists(FunctionValue otherSubclassMethod |
    otherSubclassMethod.overrides(superclassMethod) and
    exists(otherSubclassMethod.getACall())
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"