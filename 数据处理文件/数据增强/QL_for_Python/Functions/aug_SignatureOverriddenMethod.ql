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

// Identify methods with signature mismatches in inheritance hierarchies
from FunctionValue superMethod, PythonFunctionValue subMethod
where
  // Filter out cases where the superclass method is called
  not exists(superMethod.getACall()) and
  // Ensure no other overriding subclass methods are being called
  not exists(FunctionValue otherSub |
    otherSub.overrides(superMethod) and
    exists(otherSub.getACall())
  ) and
  // Exclude special methods and constructors from analysis
  not subMethod.getScope().isSpecialMethod() and
  subMethod.getName() != "__init__" and
  // Focus only on regular instance methods
  subMethod.isNormalMethod() and
  // Verify override relationship exists
  subMethod.overrides(superMethod) and
  // Check for parameter count incompatibility
  (
    // Case 1: Subclass requires more parameters than superclass provides
    subMethod.minParameters() > superMethod.maxParameters()
    or
    // Case 2: Subclass accepts fewer parameters than superclass requires
    subMethod.maxParameters() < superMethod.minParameters()
  )
select subMethod, "Overriding method '" + subMethod.getName() + "' has signature mismatch with $@.",
  superMethod, "overridden method"