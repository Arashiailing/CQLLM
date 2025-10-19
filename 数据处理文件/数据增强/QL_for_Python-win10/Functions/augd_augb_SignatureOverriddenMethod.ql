/**
 * @name Method Override Signature Incompatibility
 * @description Identifies methods in child classes that override parent class methods with
 *              incompatible parameter signatures, potentially causing runtime errors during method invocation.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python  // Python analysis module providing core functionality for Python code examination
import Expressions.CallArgs  // Module for handling expression call arguments, used in function call analysis

// Query definition: Detect signature incompatibility in method overrides between parent and child classes
from FunctionValue baseMethod, PythonFunctionValue derivedMethod  // Data sources: parent and child class methods
where
  // Method type and property checks - focus on regular business methods
  not derivedMethod.getScope().isSpecialMethod() and  // Exclude special methods
  derivedMethod.getName() != "__init__" and  // Exclude constructors
  derivedMethod.isNormalMethod() and  // Ensure it's a normal method
  
  // Override relationship verification
  derivedMethod.overrides(baseMethod) and
  
  // Parent method usage checks to avoid false positives
  not exists(baseMethod.getACall()) and  // Parent method is not called directly
  
  // Check if any sibling method overriding the same parent is being called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and  // Confirm sibling override relationship
    exists(siblingMethod.getACall())  // Verify sibling method is being called
  ) and
  
  // Parameter signature mismatch conditions
  (
    // Case 1: Derived method requires more minimum parameters than base method can accept as maximum
    derivedMethod.minParameters() > baseMethod.maxParameters()
    or
    // Case 2: Derived method can accept fewer maximum parameters than base method requires as minimum
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )

// Result output: Derived method with associated warning message
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",  // Select derived method and generate warning
  baseMethod, "overridden method"  // Select base method and mark as overridden