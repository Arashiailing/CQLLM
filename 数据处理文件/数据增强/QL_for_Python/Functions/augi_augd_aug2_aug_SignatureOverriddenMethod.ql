/**
 * @name Signature mismatch in overriding method
 * @description Detects methods in subclasses that override superclass methods
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

// Identify method pairs where a child method overrides a parent method
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish inheritance relationship: child method overrides parent method
  childMethod.overrides(parentMethod) and
  
  // Filter to only analyze regular instance methods
  // Exclude special methods and constructors from consideration
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Verify parent method is not directly called anywhere
  not exists(parentMethod.getACall()) and
  
  // Ensure no alternative overriding methods in the hierarchy are being invoked
  not exists(FunctionValue alternativeOverride |
    alternativeOverride.overrides(parentMethod) and
    exists(alternativeOverride.getACall())
  ) and
  
  // Detect parameter count incompatibility between child and parent methods
  (
    // Case 1: Child method requires more parameters than parent can provide
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Case 2: Child method accepts fewer parameters than parent requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"