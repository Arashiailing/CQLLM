/**
 * @name Signature mismatch in overriding method
 * @description Detects when a subclass method overrides a superclass method
 *              with incompatible parameter counts, potentially causing runtime errors.
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

// This query identifies methods in derived classes that override base class methods
// with incompatible signatures, specifically focusing on parameter count mismatches
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Establish inheritance relationship: derived method overrides base method
  derivedMethod.overrides(baseMethod) and
  
  // Filter to analyze only normal instance methods
  derivedMethod.isNormalMethod() and
  
  // Exclude special methods and constructors from analysis scope
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Ensure base method is not directly called in codebase
  not exists(baseMethod.getACall()) and
  
  // Verify no sibling overriding methods are being called
  not exists(FunctionValue siblingOverridingMethod |
    siblingOverridingMethod.overrides(baseMethod) and
    exists(siblingOverridingMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility between derived and base methods
  (
    // Derived method requires more parameters than base method can provide
    derivedMethod.minParameters() > baseMethod.maxParameters()
    or
    // Derived method accepts fewer parameters than base method requires
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"