/**
 * @name Signature mismatch in overriding method
 * @description Identifies situations where a subclass method overrides a superclass method
 *              with incompatible parameter counts, which can lead to runtime errors.
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

// Find pairs of methods where child method overrides parent method with incompatible signatures
from FunctionValue parentMethod, PythonFunctionValue childMethod
where
  // Establish inheritance relationship between methods
  childMethod.overrides(parentMethod) and
  
  // Focus on regular instance methods only
  childMethod.isNormalMethod() and
  
  // Exclude special methods and constructors from analysis
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  
  // Only analyze when parent method is not directly called
  not exists(parentMethod.getACall()) and
  
  // Ensure no alternative overrides of the same parent method are being called
  not exists(FunctionValue alternativeOverride |
    alternativeOverride.overrides(parentMethod) and
    exists(alternativeOverride.getACall())
  ) and
  
  // Check for parameter count incompatibilities
  (
    // Child method requires more parameters than parent method can accept
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // Child method accepts fewer parameters than parent method requires
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",
  parentMethod, "overridden method"