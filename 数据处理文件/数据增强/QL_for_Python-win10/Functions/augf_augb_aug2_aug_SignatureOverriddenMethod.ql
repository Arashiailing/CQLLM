/**
 * @name Incompatible method signature in method override
 * @description Detects instances where a subclass method overrides a superclass method
 *              with an incompatible parameter count, potentially causing runtime errors.
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

// Identify methods with incompatible signatures in inheritance hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish the override relationship and validate method type
  childMethod.overrides(parentMethod) and
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Ensure neither the parent method nor any overriding method is called
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue anotherChildMethod |
    anotherChildMethod.overrides(parentMethod) and
    exists(anotherChildMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility between parent and child methods
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"