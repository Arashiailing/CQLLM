/**
 * @name Signature mismatch in overriding method
 * @description Identifies subclass methods that override superclass methods
 *              with incompatible parameter signatures, which may lead to runtime errors.
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

// Find overriding methods with signature incompatibilities
from FunctionValue superclassMethod, PythonFunctionValue subclassMethod
where
  // Verify inheritance override relationship
  subclassMethod.overrides(superclassMethod) and
  
  // Exclude special methods and constructors from analysis scope
  not subclassMethod.getScope().isSpecialMethod() and
  subclassMethod.getName() != "__init__" and
  
  // Focus analysis on regular instance methods only
  subclassMethod.isNormalMethod() and
  
  // Check for parameter count incompatibility
  (
    // Case 1: Subclass method requires more parameters than superclass provides
    subclassMethod.minParameters() > superclassMethod.maxParameters()
    or
    // Case 2: Subclass method accepts fewer parameters than superclass requires
    subclassMethod.maxParameters() < superclassMethod.minParameters()
  ) and
  
  // Filter out cases where superclass method is directly called
  not exists(superclassMethod.getACall()) and
  
  // Exclude scenarios where other overriding subclass methods are being called
  not exists(FunctionValue otherSubclassMethod |
    otherSubclassMethod.overrides(superclassMethod) and
    exists(otherSubclassMethod.getACall())
  )
select subclassMethod, "Overriding method '" + subclassMethod.getName() + "' has signature mismatch with $@.",
  superclassMethod, "overridden method"