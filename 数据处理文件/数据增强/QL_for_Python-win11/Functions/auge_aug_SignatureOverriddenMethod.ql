/**
 * @name Signature mismatch in overriding method
 * @description Detects when a subclass method overrides a superclass method
 *              with incompatible parameter counts, potentially causing runtime errors.
 *              This query identifies methods that violate the Liskov Substitution Principle
 *              by having incompatible parameter counts with their overridden counterparts.
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

// Identify methods with signature mismatches in inheritance hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Ensure the parent method is not directly called anywhere in the codebase
  not exists(parentMethod.getACall()) and
  
  // Ensure no sibling overriding methods are called, to avoid false positives
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  ) and
  
  // Filter out special methods and constructors from our analysis
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Focus analysis only on regular instance methods
  childMethod.isNormalMethod() and
  
  // Verify that the child method actually overrides the parent method
  childMethod.overrides(parentMethod) and
  
  // Check for parameter count incompatibility between parent and child methods
  (
    // Case 1: Child method requires more parameters than parent method can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"