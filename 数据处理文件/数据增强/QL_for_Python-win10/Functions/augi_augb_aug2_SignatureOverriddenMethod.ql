/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override parent class methods with incompatible signatures.
 *              These mismatches may lead to runtime errors when method invocations expect
 *              parameters accepted by the parent method but not by the child, or conversely.
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
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Verify inheritance relationship
  childMethod.overrides(parentMethod) and
  
  // Ensure neither parent method nor any sibling overrides are called
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(parentMethod) and
    exists(siblingOverride.getACall())
  ) and
  
  // Filter out special methods, constructors, and non-normal methods
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