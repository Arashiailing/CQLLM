/**
 * @name Method Override Signature Incompatibility
 * @description Identifies methods that override parent methods but have incompatible parameter counts,
 *              which may lead to runtime errors due to signature mismatches.
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

// Identify methods with signature mismatches when overriding parent methods
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Verify the overriding relationship between methods
  derivedMethod.overrides(baseMethod) and
  
  // Ensure the derived method meets standard criteria for analysis
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  
  // Check for parameter count incompatibility between methods
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  ) and
  
  // Confirm the base method is not directly invoked in the code
  not exists(baseMethod.getACall()) and
  
  // Ensure no sibling methods that override the same base method are called
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and
    exists(siblingMethod.getACall())
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"