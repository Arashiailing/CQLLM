/**
 * @name `__init__` method calls overridden method
 * @description Detects calls from `__init__` methods to methods that are overridden by subclasses,
 *              which may lead to partially initialized instances being observed.
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
  ClassObject parentClass, string methodName, Call initCall,
  FunctionObject childClassMethod, FunctionObject parentClassMethod
where
  // Locate parent class and its initializer method
  exists(FunctionObject initializerMethod, SelfAttribute selfReference |
    parentClass.declaredAttribute("__init__") = initializerMethod and
    // Ensure method call occurs within __init__ scope
    initCall.getScope() = initializerMethod.getFunction() and
    // Verify call is made through self reference
    initCall.getFunc() = selfReference and
    // Match method name being called
    selfReference.getName() = methodName
  |
    // Retrieve method implementation in parent class
    parentClassMethod = parentClass.declaredAttribute(methodName) and
    // Confirm subclass overrides the method
    childClassMethod.overrides(parentClassMethod)
  )
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentClassMethod, methodName, childClassMethod, childClassMethod.descriptiveString()