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

// Identify methods with signature mismatches in inheritance hierarchies
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Verify core override relationship between methods
  subclassMethod.overrides(superclassMethod) and
  
  // Exclude special methods and constructors from analysis
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Focus analysis exclusively on regular instance methods
  subclassMethod.isNormalMethod() and
  
  // Check parameter count incompatibility between methods
  (
    // Case 1: Subclass requires more parameters than superclass provides
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    // Case 2: Subclass accepts fewer parameters than superclass requires
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  ) and
  
  // Filter out scenarios where superclass method is being called
  not exists(superclassMethod.getACall()) and
  
  // Ensure no other overriding subclass methods are being invoked
  not exists(FunctionValue otherSubclassMethod |
    otherSubclassMethod.overrides(superclassMethod) and
    exists(otherSubclassMethod.getACall())
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"