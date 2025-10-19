/**
 * @name `__init__` method calls overridden method
 * @description Identifies when an `__init__` method invokes methods that are overridden in subclasses,
 *              which could lead to partially initialized objects being exposed to subclass code.
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
  ClassObject parentClass, string targetMethodName, Call initMethodCall,
  FunctionObject overridingMethod, FunctionObject parentMethod
where
  exists(FunctionObject initializerMethod, SelfAttribute selfReference |
    // Locate the __init__ method of the parent class
    parentClass.declaredAttribute("__init__") = initializerMethod and
    // Ensure the method call is inside the __init__ method
    initMethodCall.getScope() = initializerMethod.getFunction() and
    // Verify the call is made through a self reference
    initMethodCall.getFunc() = selfReference and
    // Extract the name of the method being called
    selfReference.getName() = targetMethodName and
    // Find the method implementation in the parent class
    parentMethod = parentClass.declaredAttribute(targetMethodName) and
    // Confirm that a subclass overrides this parent method
    overridingMethod.overrides(parentMethod)
  )
select initMethodCall, 
  "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentMethod, targetMethodName, 
  overridingMethod, overridingMethod.descriptiveString()