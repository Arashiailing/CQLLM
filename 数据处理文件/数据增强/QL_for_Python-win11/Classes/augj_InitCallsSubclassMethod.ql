/**
 * @name `__init__` method calls overridden method
 * @description Detects when an `__init__` method invokes a method that is overridden by a subclass,
 *              potentially exposing a partially initialized instance.
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
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject childMethod, FunctionObject parentMethod
where
  // Identify the __init__ method of the parent class
  exists(FunctionObject initMethod |
    parentClass.declaredAttribute("__init__") = initMethod and
    // Ensure the call occurs within the __init__ method's scope
    methodCall.getScope() = initMethod.getFunction() and
    // Verify the call targets a self attribute
    exists(SelfAttribute selfAttr |
      methodCall.getFunc() = selfAttr and
      // Match the self attribute name with our method name
      selfAttr.getName() = methodName
    )
  |
    // Retrieve the method as declared in the parent class
    parentMethod = parentClass.declaredAttribute(methodName) and
    // Confirm that a child class method overrides the parent method
    childMethod.overrides(parentMethod)
  )
// Report the problematic call with detailed context
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName,
  childMethod, childMethod.descriptiveString()