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
from FunctionValue overriddenMethod, PythonFunctionValue overridingMethod
where
  // Establish inheritance relationship
  overridingMethod.overrides(overriddenMethod) and
  
  // Exclude special methods and constructors
  overridingMethod.isNormalMethod() and
  not overridingMethod.getScope().isSpecialMethod() and
  overridingMethod.getName() != "__init__" and
  
  // Detect parameter count incompatibility
  (
    overridingMethod.minParameters() > overriddenMethod.maxParameters() or
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  ) and
  
  // Verify no overridden methods in hierarchy are called
  not exists(FunctionValue methodInHierarchy |
    (methodInHierarchy = overriddenMethod or methodInHierarchy.overrides(overriddenMethod)) and
    exists(methodInHierarchy.getACall())
  )
select overridingMethod, "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",
  overriddenMethod, "overridden method"