/**
 * @name Signature mismatch in overriding method
 * @description Detects overriding methods with incompatible signatures compared to their parent methods.
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

// Find overriding methods with signature incompatibilities
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish inheritance relationship
  childMethod.overrides(parentMethod) and
  
  // Ensure parent method is never directly invoked
  not exists(parentMethod.getACall()) and
  
  // Verify no sibling overriding methods are called in the hierarchy
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  ) and
  
  // Exclude special methods and constructors from analysis
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  
  // Identify parameter count incompatibilities
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"