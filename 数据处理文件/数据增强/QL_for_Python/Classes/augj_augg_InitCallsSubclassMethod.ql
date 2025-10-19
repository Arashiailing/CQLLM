/**
 * @name `__init__` method calls overridden method
 * @description Detects when a parent class's `__init__` method invokes a method that is overridden by a subclass,
 *              which may lead to observing partially initialized instances.
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
  ClassObject parentClass, string methodIdentifier, Call methodCall, 
  FunctionObject overridingMethod, FunctionObject originalMethod
where
  // Identify the parent class's __init__ method
  exists(FunctionObject initializerMethod |
    parentClass.declaredAttribute("__init__") = initializerMethod and
    // Ensure the call occurs within the __init__ method's scope
    methodCall.getScope() = initializerMethod.getFunction()
  |
    // Verify the call is made through a self reference
    exists(SelfAttribute selfReference |
      methodCall.getFunc() = selfReference and
      // Extract the method name being called
      selfReference.getName() = methodIdentifier and
      // Retrieve the original method declaration in the parent class
      originalMethod = parentClass.declaredAttribute(methodIdentifier) and
      // Confirm that a subclass method overrides the parent method
      overridingMethod.overrides(originalMethod)
    )
  )
// Output warning with call node, overridden method name, and overriding method details
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
       originalMethod, methodIdentifier, overridingMethod, overridingMethod.descriptiveString()