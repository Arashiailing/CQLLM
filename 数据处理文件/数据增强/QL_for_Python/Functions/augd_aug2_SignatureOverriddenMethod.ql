/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override a parent method but have incompatible signatures.
 *              Such mismatches can lead to runtime errors when the method is called with
 *              arguments expected by the parent but not accepted by the child, or vice versa.
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
  // Condition 1: The parent method must never be called directly
  not exists(overriddenMethod.getACall()) and
  
  // Condition 2: No sibling overrides of the same parent method are ever called
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(overriddenMethod) and
    exists(siblingOverride.getACall())
  ) and
  
  // Condition 3: The overriding method must be a normal method (not special or constructor)
  not overridingMethod.getScope().isSpecialMethod() and
  overridingMethod.getName() != "__init__" and
  overridingMethod.isNormalMethod() and
  
  // Condition 4: Verify inheritance relationship
  overridingMethod.overrides(overriddenMethod) and
  
  // Condition 5: Signature incompatibility detection
  (
    // Case A: Child requires more arguments than parent can accept
    overridingMethod.minParameters() > overriddenMethod.maxParameters() or
    // Case B: Child accepts fewer arguments than parent requires
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  )
select overridingMethod, 
  "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",
  overriddenMethod, 
  "overridden method"