/**
 * @name Method Override Signature Incompatibility
 * @description Detects methods in subclasses that override parent class methods with
 *              incompatible parameter signatures, which may lead to runtime errors during method invocation.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python  // Core module for Python code analysis
import Expressions.CallArgs  // Module for handling call arguments in expressions

// Query to find signature incompatibilities in method overrides between parent and child classes
from FunctionValue parentMethod, PythonFunctionValue childMethod  // Source data: parent and child class methods
where
  // Method type verification - focus on standard business methods
  not childMethod.getScope().isSpecialMethod() and  // Exclude special Python methods
  childMethod.getName() != "__init__" and  // Exclude class constructors
  childMethod.isNormalMethod() and  // Confirm it's a regular method
  
  // Override relationship validation
  childMethod.overrides(parentMethod) and
  
  // Parent method usage analysis to reduce false positives
  not exists(parentMethod.getACall()) and  // Parent method is not directly called
  
  // Check for active sibling overrides to avoid false alarms
  not exists(FunctionValue siblingOverrideMethod |
    siblingOverrideMethod.overrides(parentMethod) and  // Verify sibling override relationship
    exists(siblingOverrideMethod.getACall())  // Confirm sibling method is in use
  ) and
  
  // Parameter signature incompatibility detection
  (
    // Scenario 1: Child method requires more minimum parameters than parent method can accept as maximum
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Scenario 2: Child method can accept fewer maximum parameters than parent method requires as minimum
    childMethod.maxParameters() < parentMethod.minParameters()
  )

// Output results: Child method with associated warning message
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",  // Select child method and generate warning
  parentMethod, "overridden method"  // Select parent method and mark as overridden