/**
 * @name Method override signature incompatibility
 * @description Detects inheritance scenarios where a child class method overrides a parent class method
 *              with incompatible parameter counts, potentially causing runtime errors during method resolution.
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

// Identify overridden method pairs with signature incompatibilities
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify override relationship between methods
  childMethod.overrides(parentMethod) and
  
  // Filter to standard instance methods (exclude special methods and constructors)
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Exclude cases where parent method is directly invoked
  not exists(parentMethod.getACall()) and
  
  // Ensure no sibling overriding methods are being called
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(parentMethod) and
    exists(siblingOverride.getACall())
  ) and
  
  // Detect parameter count incompatibility scenarios
  (
    // Case 1: Child method requires more parameters than parent can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"