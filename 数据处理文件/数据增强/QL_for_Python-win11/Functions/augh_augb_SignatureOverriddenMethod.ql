/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods in child classes that override parent methods with incompatible
 *              parameter signatures, potentially causing runtime errors during method invocation.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python  // Python code analysis foundation module
import Expressions.CallArgs  // Module for handling function call arguments

// Query to detect signature mismatches in method overriding scenarios
from FunctionValue overriddenMethod, PythonFunctionValue overridingMethod  // Source data: parent and child methods
where
  // Condition 1: The parent method should not be directly called to avoid false positives
  not exists(overriddenMethod.getACall()) and
  
  // Condition 2: No sibling method that overrides the same parent method should be called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(overriddenMethod) and  // Verify override relationship
    exists(siblingMethod.getACall())  // Confirm it's being used
  ) and
  
  // Condition 3: Filter out special methods and constructors to focus on business logic methods
  not overridingMethod.getScope().isSpecialMethod() and  // Exclude special methods
  overridingMethod.getName() != "__init__" and  // Exclude constructors
  overridingMethod.isNormalMethod() and  // Ensure it's a regular method
  
  // Condition 4: Verify override relationship exists between methods
  overridingMethod.overrides(overriddenMethod) and
  
  // Condition 5: Check for parameter signature incompatibility
  (
    // Case 1: Child method requires more minimum parameters than parent can accept
    overridingMethod.minParameters() > overriddenMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer maximum parameters than parent requires
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  )

// Output: Child method with warning message and reference to the overridden parent method
select overridingMethod, "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",  // Main result: problematic child method
  overriddenMethod, "overridden method"  // Secondary result: parent method being overridden