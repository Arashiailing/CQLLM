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

// Identify overriding methods with signature mismatches
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Verify inheritance override relationship
  subclassMethod.overrides(superclassMethod) and
  
  // Restrict to normal instance methods (exclude special methods and constructors)
  subclassMethod.isNormalMethod() and
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Exclude cases where superclass method is directly called
  not exists(superclassMethod.getACall()) and
  
  // Ensure no alternative overriding methods are being called
  not exists(FunctionValue alternativeSubclassMethod |
    alternativeSubclassMethod.overrides(superclassMethod) and
    exists(alternativeSubclassMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility between subclass and superclass methods
  (
    // Case 1: Subclass requires more parameters than superclass can provide
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    // Case 2: Subclass accepts fewer parameters than superclass requires
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"