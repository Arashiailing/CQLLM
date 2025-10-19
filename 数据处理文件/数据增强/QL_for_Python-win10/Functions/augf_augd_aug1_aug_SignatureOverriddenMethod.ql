/**
 * @name Incompatible method signature in override
 * @description Identifies overriding methods with parameter count mismatches
 *              relative to their superclass methods, which may cause runtime failures.
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

// Detect signature mismatches between overridden and overriding methods
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish valid override relationship
  childMethod.overrides(parentMethod) and
  
  // Exclude special methods and constructors from analysis scope
  (
    not childMethod.getScope().isSpecialMethod() and
    childMethod.getName() != "__init__" and
    childMethod.isNormalMethod()
  ) and
  
  // Validate parameter count incompatibility
  (
    // Child method requires more parameters than parent can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Child method accepts fewer parameters than parent requires
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  
  // Filter out scenarios where parent method is actively called
  not exists(parentMethod.getACall()) and
  
  // Ensure no other overriding methods are being invoked
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(parentMethod) and
    exists(siblingMethod.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"