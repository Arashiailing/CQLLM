/**
 * @name Method override signature incompatibility
 * @description Identifies inheritance scenarios where a child class method overrides a parent class method
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

// Find overriding methods with signature mismatches
from FunctionValue overriddenMethod, PythonFunctionValue overridingMethod
where
  // Verify override relationship between methods
  overridingMethod.overrides(overriddenMethod) and
  
  // Filter standard instance methods (exclude special methods and constructors)
  overridingMethod.isNormalMethod() and
  not overridingMethod.getScope().isSpecialMethod() and
  overridingMethod.getName() != "__init__" and
  
  // Exclude cases where parent method is directly invoked
  not exists(overriddenMethod.getACall()) and
  
  // Ensure no sibling overriding methods are being called
  not exists(FunctionValue siblingOverridingMethod |
    siblingOverridingMethod.overrides(overriddenMethod) and
    exists(siblingOverridingMethod.getACall())
  ) and
  
  // Detect parameter count incompatibility scenarios
  (
    // Child method requires more parameters than parent can provide
    overridingMethod.minParameters() > overriddenMethod.maxParameters()
    or
    // Child method accepts fewer parameters than parent requires
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  )
select overridingMethod, "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",
  overriddenMethod, "overridden method"