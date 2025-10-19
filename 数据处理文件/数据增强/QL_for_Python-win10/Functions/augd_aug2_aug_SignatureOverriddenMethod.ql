/**
 * @name Signature mismatch in overriding method
 * @description Identifies subclass methods that override superclass methods
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

// Find method pairs with signature mismatches in inheritance hierarchies
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Establish that the subclass method overrides the superclass method
  subclassMethod.overrides(superclassMethod) and
  
  // Restrict analysis to regular instance methods only
  // Exclude special methods and constructors from consideration
  subclassMethod.isNormalMethod() and
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Filter out scenarios where the superclass method is directly invoked
  not exists(superclassMethod.getACall()) and
  
  // Ensure no other overriding methods in the hierarchy are being called
  not exists(FunctionValue otherOverridingMethod |
    otherOverridingMethod.overrides(superclassMethod) and
    exists(otherOverridingMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility between subclass and superclass methods
  (
    // Case 1: Subclass method requires more parameters than superclass can provide
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    // Case 2: Subclass method accepts fewer parameters than superclass requires
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"