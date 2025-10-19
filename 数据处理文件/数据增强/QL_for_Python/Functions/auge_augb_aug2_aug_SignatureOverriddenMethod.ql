/**
 * @name Incompatible method signature in method override
 * @description Detects method overrides where the subclass method has a parameter count
 *              incompatible with the superclass method, potentially causing runtime errors.
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

// Identify overriding methods with signature incompatibilities
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Verify inheritance relationship and method characteristics
  derivedMethod.overrides(baseMethod) and
  derivedMethod.isNormalMethod() and
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Ensure neither base method nor any overriding method is invoked
  not exists(FunctionValue method |
    (method = baseMethod or method.overrides(baseMethod)) and
    exists(method.getACall())
  ) and
  
  // Detect parameter count incompatibility
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"