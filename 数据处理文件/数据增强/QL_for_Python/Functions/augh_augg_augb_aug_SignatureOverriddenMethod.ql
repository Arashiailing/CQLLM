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

// This query detects methods in child classes that override parent class methods
// with incompatible signatures, focusing specifically on parameter count mismatches
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish inheritance relationship: child method overrides parent method
  childMethod.overrides(parentMethod) and
  
  // Filter to examine only regular instance methods
  childMethod.isNormalMethod() and
  
  // Exclude special methods and constructors from analysis scope
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Ensure parent method is not directly invoked in the codebase
  not exists(parentMethod.getACall()) and
  
  // Verify no sibling overriding methods are being called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility between child and parent methods
  (
    // Case 1: Child method requires more parameters than parent method can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"