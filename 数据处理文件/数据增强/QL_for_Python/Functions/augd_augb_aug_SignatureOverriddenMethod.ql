/**
 * @name Signature mismatch in overriding method
 * @description Detects when a subclass method overrides a superclass method
 *              with incompatible parameter counts, potentially causing runtime errors.
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
from FunctionValue overriddenMethod, PythonFunctionValue overridingMethod
where
  // Establish inheritance relationship
  overridingMethod.overrides(overriddenMethod) and
  // Focus on regular instance methods only
  overridingMethod.isNormalMethod() and
  // Exclude special methods and constructors
  (
    not overridingMethod.getScope().isSpecialMethod() and
    overridingMethod.getName() != "__init__"
  ) and
  // Filter cases where superclass method is invoked
  not exists(overriddenMethod.getACall()) and
  // Ensure no sibling overriding methods are called
  not exists(FunctionValue siblingOverridingMethod |
    siblingOverridingMethod.overrides(overriddenMethod) and
    exists(siblingOverridingMethod.getACall())
  ) and
  // Detect parameter count incompatibility
  (
    // Case 1: Subclass requires more parameters than superclass provides
    overridingMethod.minParameters() > overriddenMethod.maxParameters()
    or
    // Case 2: Subclass accepts fewer parameters than superclass requires
    overridingMethod.maxParameters() < overriddenMethod.minParameters()
  )
select overridingMethod, "Overriding method '" + overridingMethod.getName() + "' has signature mismatch with $@.",
  overriddenMethod, "overridden method"