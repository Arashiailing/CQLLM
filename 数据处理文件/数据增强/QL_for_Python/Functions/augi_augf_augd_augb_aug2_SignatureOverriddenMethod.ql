/**
 * @name Signature mismatch in overriding method
 * @description Identifies overriding methods in subclasses with incompatible signatures
 *              compared to their parent class methods. Such mismatches may cause runtime
 *              errors when method calls expect arguments accepted by the parent but
 *              rejected by the child, or vice versa.
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

// Identify child methods that override parent methods with incompatible signatures
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish inheritance relationship between methods
  childMethod.overrides(parentMethod) and
  
  // Exclude special methods, constructors, and non-normal methods
  childMethod.isNormalMethod() and
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Verify parameter count incompatibility between child and parent methods
  (
    // Child method requires more parameters than parent method's maximum
    childMethod.minParameters() > parentMethod.maxParameters() or
    // Child method accepts fewer parameters than parent method's minimum
    childMethod.maxParameters() < parentMethod.minParameters()
  ) and
  
  // Ensure neither the parent method nor any ancestor methods are called in the codebase
  not exists(FunctionValue ancestor |
    (ancestor = parentMethod or ancestor.overrides(parentMethod)) and
    exists(ancestor.getACall())
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"