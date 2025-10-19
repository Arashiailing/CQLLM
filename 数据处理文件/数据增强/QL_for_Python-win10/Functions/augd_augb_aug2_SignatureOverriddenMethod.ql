/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override parent methods with incompatible signatures.
 *              Such mismatches may cause runtime errors when method calls expect arguments
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
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish inheritance relationship
  childMethod.overrides(parentMethod) and
  
  // Verify no overridden methods in hierarchy are called
  not exists(FunctionValue overriddenMethod |
    (overriddenMethod = parentMethod or overriddenMethod.overrides(parentMethod)) and
    exists(overriddenMethod.getACall())
  ) and
  
  // Exclude special methods and constructors
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  
  // Detect parameter count incompatibility
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"