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
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Ensure we're analyzing valid override relationships
  childMethod.overrides(parentMethod) and
  
  // Focus only on regular instance methods, excluding special methods and constructors
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Filter out cases where methods are being called elsewhere in the code
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue otherChild |
    otherChild.overrides(parentMethod) and
    exists(otherChild.getACall())
  ) and
  
  // Check for parameter count incompatibility between parent and child methods
  (
    // Case 1: Child method requires more parameters than parent method provides
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"