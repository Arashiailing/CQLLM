/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override parent methods with incompatible signatures.
 *              Such mismatches may cause runtime errors when method calls expect arguments
 *              accepted by the parent but rejected by the child, or vice versa.
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

// Find methods in subclasses that override superclass methods with incompatible signatures
from FunctionValue superClassMethod, PythonFunctionValue subClassMethod
where
  // Establish inheritance relationship between methods
  subClassMethod.overrides(superClassMethod) and
  
  // Ensure that neither the superclass method nor any ancestor methods are called in the codebase
  not exists(FunctionValue ancestorMethod |
    (ancestorMethod = superClassMethod or ancestorMethod.overrides(superClassMethod)) and
    exists(ancestorMethod.getACall())
  ) and
  
  // Filter out special methods, constructors, and non-normal methods
  subClassMethod.isNormalMethod() and
  not subClassMethod.getScope().isSpecialMethod() and
  subClassMethod.getName() != "__init__" and
  
  // Check for parameter count incompatibility between subclass and superclass methods
  (
    // Subclass method requires more parameters than superclass method maximum
    subClassMethod.minParameters() > superClassMethod.maxParameters() or
    // Subclass method accepts fewer parameters than superclass method minimum
    subClassMethod.maxParameters() < superClassMethod.minParameters()
  )
select subClassMethod, "Overriding method '" + subClassMethod.getName() + "' has signature mismatch with $@.",
  superClassMethod, "overridden method"