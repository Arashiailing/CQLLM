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

// Identifying methods with signature mismatches in inheritance hierarchies
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify override relationship exists
  childMethod.overrides(parentMethod) and
  // Focus only on regular instance methods
  childMethod.isNormalMethod() and
  // Exclude special methods and constructors from analysis
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  // Filter out cases where the superclass method is called
  not exists(parentMethod.getACall()) and
  // Ensure no other overriding subclass methods are being called
  not exists(FunctionValue otherOverridingMethod |
    otherOverridingMethod.overrides(parentMethod) and
    exists(otherOverridingMethod.getACall())
  ) and
  // Check for parameter count incompatibility
  (
    // Case 1: Subclass requires more parameters than superclass provides
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Subclass accepts fewer parameters than superclass requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"