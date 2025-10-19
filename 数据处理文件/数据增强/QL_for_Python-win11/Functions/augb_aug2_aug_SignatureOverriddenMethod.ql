/**
 * @name Incompatible method signature in method override
 * @description Identifies situations where a method in a subclass overrides a superclass method
 *              with an incompatible number of parameters, which may lead to runtime errors.
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

// Find methods with incompatible signatures in inheritance relationships
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Establish override relationship and ensure it's a standard instance method
  subclassMethod.overrides(superclassMethod) and
  subclassMethod.isNormalMethod() and
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Verify that neither the superclass method nor any other overriding method is called
  not exists(superclassMethod.getACall()) and
  not exists(FunctionValue otherSubclassMethod |
    otherSubclassMethod.overrides(superclassMethod) and
    exists(otherSubclassMethod.getACall())
  ) and
  
  // Check for parameter count incompatibility
  (
    subclassMethod.minParameters() > superclassMethod.maxParameters() or
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"