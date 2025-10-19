/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods in child classes that override parent class methods
 *              with incompatible parameter signatures, potentially causing runtime
 *              errors during method invocation.
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

from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Establish inheritance relationship between methods
  subclassMethod.overrides(superclassMethod) and
  
  // Filter out special methods and constructors to focus on business logic
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  subclassMethod.isNormalMethod() and
  
  // Verify that the superclass method is not directly called
  not exists(superclassMethod.getACall()) and
  
  // Ensure no other subclass method overriding the same superclass method is being used
  not exists(FunctionValue otherSubclassMethod |
    otherSubclassMethod.overrides(superclassMethod) and
    exists(otherSubclassMethod.getACall())
  ) and
  
  // Detect parameter signature incompatibility
  (
    // Case 1: Subclass method requires more minimum parameters than superclass can accept
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    // Case 2: Subclass method accepts fewer maximum parameters than superclass requires
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  )

select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"