/**
 * @name Signature mismatch in overriding method
 * @description Identifies methods that override parent methods with incompatible signatures.
 *              Such mismatches can cause runtime errors when method calls expect arguments
 *              accepted by the parent but rejected by the child, or vice versa.
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

// Identify overriding methods with signature mismatches
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Verify inheritance relationship exists
  derivedMethod.overrides(baseMethod) and
  
  // Ensure base method is never called directly
  not exists(baseMethod.getACall()) and
  
  // Confirm no other overriding methods in the hierarchy are called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and
    exists(siblingMethod.getACall())
  ) and
  
  // Filter out special methods and constructors
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  
  // Detect parameter count incompatibility
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"