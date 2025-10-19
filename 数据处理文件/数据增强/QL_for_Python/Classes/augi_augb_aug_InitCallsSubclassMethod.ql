/**
 * @name Initialization method invokes overridden method
 * @description Identifies invocations within `__init__` methods targeting functions that could be overridden by derived classes,
 *              potentially leading to exposure of partially constructed instances.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from
  ClassObject parentClass, string methodName, Call initializationCall,
  FunctionObject derivedClassMethod, FunctionObject parentClassMethod
where
  // Identify the initialization method of the parent class
  exists(FunctionObject initializationMethod |
    parentClass.declaredAttribute("__init__") = initializationMethod and
    initializationCall.getScope() = initializationMethod.getFunction()
  |
    // Confirm the call is to a self attribute method
    exists(SelfAttribute selfAttr |
      initializationCall.getFunc() = selfAttr and
      selfAttr.getName() = methodName
    |
      // Validate the method exists in parent class and is overridden
      parentClassMethod = parentClass.declaredAttribute(methodName) and
      derivedClassMethod.overrides(parentClassMethod)
    )
  )
// Generate alert with method call details and override information
select initializationCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentClassMethod, methodName, derivedClassMethod, derivedClassMethod.descriptiveString()