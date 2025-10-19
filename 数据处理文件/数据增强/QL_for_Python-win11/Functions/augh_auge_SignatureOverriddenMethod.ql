/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override base methods with incompatible parameter counts,
 *              potentially leading to runtime errors when method resolution occurs.
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

from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Filter for regular methods in derived classes (excluding special methods and constructors)
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Establish inheritance relationship
  childMethod.overrides(parentMethod) and
  
  // Detect parameter count incompatibility between parent and child methods
  (
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  
  // Verify the parent method is never directly called
  not exists(parentMethod.getACall()) and
  
  // Ensure no sibling methods (other overrides of the same parent) are called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  )
select childMethod, 
  "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.", 
  parentMethod, 
  "overridden method"