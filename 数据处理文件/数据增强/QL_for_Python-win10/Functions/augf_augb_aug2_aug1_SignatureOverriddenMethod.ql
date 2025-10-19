/**
 * @name Signature mismatch in overriding method
 * @description Identifies overriding methods in Python classes that have incompatible parameter counts
 *              relative to their parent class methods. Such signature mismatches can lead to runtime errors
 *              when methods are invoked, as the expected and actual parameter counts don't align properly.
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

// Find pairs of base class methods and their derived class overrides with parameter count mismatches
from FunctionValue baseClassMethod, PythonFunctionValue derivedClassMethod
where
  // Validate that the base class method is never directly invoked
  not exists(baseClassMethod.getACall()) and
  
  // Verify that no sibling overriding methods are called
  not exists(FunctionValue siblingOverrideMethod |
    siblingOverrideMethod.overrides(baseClassMethod) and
    exists(siblingOverrideMethod.getACall())
  ) and
  
  // Ensure the derived class method meets standard method criteria
  not derivedClassMethod.getScope().isSpecialMethod() and
  derivedClassMethod.getName() != "__init__" and
  derivedClassMethod.isNormalMethod() and
  
  // Confirm that an overriding relationship exists between the methods
  derivedClassMethod.overrides(baseClassMethod) and
  
  // Check for parameter count incompatibility between the methods
  (
    derivedClassMethod.minParameters() > baseClassMethod.maxParameters() or
    derivedClassMethod.maxParameters() < baseClassMethod.minParameters()
  )
select derivedClassMethod, "Overriding method '" + derivedClassMethod.getName() + "' has signature mismatch with $@.",
  baseClassMethod, "overridden method"