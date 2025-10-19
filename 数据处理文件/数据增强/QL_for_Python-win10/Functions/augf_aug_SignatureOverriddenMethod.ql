/**
 * @name Signature mismatch in overriding method
 * @description Identifies instances where a subclass method overrides a superclass method
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

// Find methods with signature incompatibilities in inheritance hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish the override relationship between methods
  childMethod.overrides(parentMethod) and
  
  // Filter to focus only on regular instance methods, excluding special cases
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Exclude scenarios where the superclass method is being called
  not exists(parentMethod.getACall()) and
  
  // Ensure no other overriding subclass methods are being invoked
  not exists(FunctionValue otherChild |
    otherChild.overrides(parentMethod) and
    exists(otherChild.getACall())
  ) and
  
  // Detect parameter count incompatibility between parent and child methods
  (
    // Scenario 1: Child method requires more parameters than parent method can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Scenario 2: Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"