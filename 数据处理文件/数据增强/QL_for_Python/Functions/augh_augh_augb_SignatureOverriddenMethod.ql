/**
 * @name Signature mismatch in overriding method
 * @description Detects methods in subclasses that override parent methods with incompatible
 *              parameter signatures, which may lead to runtime errors when the method is called.
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

// Query to identify signature incompatibilities in method inheritance hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod  // Source data: parent and child methods
where
  // Condition 1: Exclude parent methods that are directly called to reduce false positives
  not exists(parentMethod.getACall()) and
  
  // Condition 2: Exclude cases where any sibling method overriding the same parent is called
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(parentMethod) and  // Verify override relationship
    exists(siblingOverride.getACall())  // Confirm it's being used
  ) and
  
  // Condition 3: Focus on regular business logic methods by filtering out special methods
  not childMethod.getScope().isSpecialMethod() and  // Exclude special methods
  childMethod.getName() != "__init__" and  // Exclude constructors
  childMethod.isNormalMethod() and  // Ensure it's a regular method
  
  // Condition 4: Establish that the child method actually overrides the parent method
  childMethod.overrides(parentMethod) and
  
  // Condition 5: Check for parameter signature incompatibility between parent and child
  (
    // Case 1: Child method requires more minimum parameters than parent can accept
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer maximum parameters than parent requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )

// Output: Child method with warning message and reference to the overridden parent method
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",  // Main result: problematic child method
  parentMethod, "overridden method"  // Secondary result: parent method being overridden