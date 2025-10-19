/**
 * @name Incompatible method signature in method override
 * @description Detects method overrides in subclasses that have an incompatible number of parameters
 *              compared to the superclass method. Such mismatches can cause runtime errors.
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

// Identify method signature mismatches in inheritance hierarchies
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Verify override relationship and method characteristics
  derivedMethod.overrides(baseMethod) and
  derivedMethod.isNormalMethod() and
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Ensure neither base method nor any overriding method is called
  not exists(baseMethod.getACall()) and
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(baseMethod) and
    exists(otherDerivedMethod.getACall())
  ) and
  
  // Check parameter count incompatibility conditions
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"