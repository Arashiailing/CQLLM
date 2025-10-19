/**
 * @name Method Override Signature Incompatibility
 * @description Identifies subclass methods that override superclass methods
 *              with mismatched parameter counts, which may lead to runtime exceptions.
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

// Find methods with incompatible signatures in inheritance hierarchies
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // Method relationship conditions
  derivedMethod.overrides(baseMethod) and
  
  // Method type filtering conditions
  derivedMethod.isNormalMethod() and
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  
  // Method call filtering conditions
  not exists(baseMethod.getACall()) and
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(baseMethod) and
    exists(otherDerivedMethod.getACall())
  ) and
  
  // Parameter incompatibility conditions
  (
    derivedMethod.minParameters() > baseMethod.maxParameters()
    or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"