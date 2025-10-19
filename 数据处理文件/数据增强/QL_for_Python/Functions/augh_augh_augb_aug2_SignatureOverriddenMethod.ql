/**
 * @name Signature mismatch in overriding method
 * @description Identifies overriding methods with signatures incompatible with their parent methods.
 *              Such mismatches may cause runtime errors when method calls pass arguments
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

// Identify overriding methods with signature incompatibilities
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Establish inheritance relationship
  derivedMethod.overrides(baseMethod) and
  
  // Verify base method is never directly invoked
  not exists(baseMethod.getACall()) and
  
  // Ensure no sibling overriding methods are called in the hierarchy
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and
    exists(siblingMethod.getACall())
  ) and
  
  // Exclude special methods and constructors from analysis
  (
    not derivedMethod.getScope().isSpecialMethod() and
    derivedMethod.getName() != "__init__" and
    derivedMethod.isNormalMethod()
  ) and
  
  // Detect parameter count incompatibilities
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"