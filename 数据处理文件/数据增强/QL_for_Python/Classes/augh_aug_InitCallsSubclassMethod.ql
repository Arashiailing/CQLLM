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
  ClassObject superClass, string targetMethodName, Call initMethodCall,
  FunctionObject subClassMethod, FunctionObject superClassMethod
where
  // Identify parent class and its __init__ method
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    superClass.declaredAttribute("__init__") = initMethod and
    // Ensure method call occurs within __init__ scope
    initMethodCall.getScope() = initMethod.getFunction() and
    // Verify call is made through self reference
    initMethodCall.getFunc() = selfAttr and
    // Match method name being called
    selfAttr.getName() = targetMethodName
  |
    // Retrieve method implementation in parent class
    superClassMethod = superClass.declaredAttribute(targetMethodName) and
    // Confirm subclass overrides the method
    subClassMethod.overrides(superClassMethod)
  )
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superClassMethod, targetMethodName, subClassMethod, subClassMethod.descriptiveString()