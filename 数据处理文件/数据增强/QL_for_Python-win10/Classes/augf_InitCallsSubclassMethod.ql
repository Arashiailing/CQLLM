/**
 * @name `__init__` method calls overridden method
 * @description Detects calls within `__init__` methods to functions that are overridden by subclasses,
 *              potentially exposing partially initialized objects to subclass implementations.
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
  ClassObject superClass, string methodName, Call methodCall, 
  FunctionObject subClassMethod, FunctionObject superClassMethod
where
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // Identify the class's __init__ method
    superClass.declaredAttribute("__init__") = initMethod and
    // Ensure the call occurs within the __init__ method's scope
    methodCall.getScope() = initMethod.getFunction() and
    // Verify the call targets a self attribute
    methodCall.getFunc() = selfAttr and
    // Match the called attribute name to our method name variable
    selfAttr.getName() = methodName and
    // Locate the method implementation in the parent class
    superClassMethod = superClass.declaredAttribute(methodName) and
    // Confirm a subclass method overrides the parent implementation
    subClassMethod.overrides(superClassMethod)
  )
select methodCall, 
  "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superClassMethod, methodName, 
  subClassMethod, subClassMethod.descriptiveString()