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

// Identify overriding methods with signature incompatibilities
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Establish inheritance relationship
  subclassMethod.overrides(superclassMethod) and
  
  // Restrict to standard instance methods
  subclassMethod.isNormalMethod() and
  
  // Exclude special methods and constructors
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Filter cases where superclass method is actively used
  not exists(superclassMethod.getACall()) and
  
  // Ensure no other overriding methods are called
  not exists(FunctionValue otherOverridingMethod |
    otherOverridingMethod.overrides(superclassMethod) and
    exists(otherOverridingMethod.getACall())
  ) and
  
  // Detect parameter count mismatches
  (
    // Subclass requires more parameters than superclass supports
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    // Subclass accepts fewer parameters than superclass requires
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"