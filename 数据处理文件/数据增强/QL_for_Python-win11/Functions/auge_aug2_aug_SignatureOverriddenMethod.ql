/**
 * @name Method override signature incompatibility
 * @description Identifies cases where a derived class method overrides a base class method
 *              with incompatible parameter counts, which may lead to runtime exceptions.
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

// Find methods in inheritance hierarchies with incompatible signatures
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Establish that the derived method overrides the base method
  derivedMethod.overrides(baseMethod) and
  
  // Restrict to standard instance methods (excluding special methods and constructors)
  derivedMethod.isNormalMethod() and
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Exclude cases where the base method is directly called
  not exists(baseMethod.getACall()) and
  
  // Ensure no other overriding methods are being invoked
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and
    exists(siblingMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility between derived and base methods
  (
    // Scenario 1: Derived method requires more parameters than base method can provide
    derivedMethod.minParameters() > baseMethod.maxParameters()
    or
    // Scenario 2: Derived method accepts fewer parameters than base method requires
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"