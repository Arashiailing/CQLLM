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
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Verify that the subclass method properly overrides a superclass method
  subclassMethod.overrides(superclassMethod) and
  
  // Restrict analysis to normal instance methods only, excluding special methods and constructors
  subclassMethod.isNormalMethod() and
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Eliminate false positives by excluding cases where:
  // 1. The superclass method is directly called, or
  // 2. Any sibling override method is called
  not exists(superclassMethod.getACall()) and
  not exists(FunctionValue siblingOverrideMethod |
    siblingOverrideMethod.overrides(superclassMethod) and
    exists(siblingOverrideMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility that violates the Liskov Substitution Principle:
  // - Subclass method requires more parameters than superclass can provide, OR
  // - Subclass method accepts fewer parameters than superclass requires
  (
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"