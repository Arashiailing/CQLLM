/**
 * @name Signature mismatch in overriding method
 * @description Detects potential runtime errors caused by method overriding
 *              with incompatible parameter signatures in inheritance hierarchies.
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
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify the override relationship between child and parent methods
  childMethod.overrides(parentMethod) and
  
  // Focus analysis on regular instance methods only
  childMethod.isNormalMethod() and
  
  // Exclude special methods and constructors from consideration
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Check for parameter count incompatibility
  exists(
    int parentMin, int parentMax, int childMin, int childMax |
    parentMin = parentMethod.minParameters() and
    parentMax = parentMethod.maxParameters() and
    childMin = childMethod.minParameters() and
    childMax = childMethod.maxParameters() and
    (
      // Case 1: Child method requires more parameters than parent provides
      childMin > parentMax
      or
      // Case 2: Child method accepts fewer parameters than parent requires
      childMax < parentMin
    )
  ) and
  
  // Filter out scenarios where the parent method is being called
  not exists(parentMethod.getACall()) and
  
  // Ensure no other overriding child methods are being called
  not exists(FunctionValue otherChildMethod |
    otherChildMethod.overrides(parentMethod) and
    exists(otherChildMethod.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"