/**
 * @name `__init__` method calls overridden method
 * @description Detects when an `__init__` method calls a method that is overridden by a subclass.
 *              This can lead to a partially initialized instance being observed by the subclass method,
 *              potentially causing unexpected behavior or errors.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify calls in parent class initializers to methods overridden by subclasses
from
  ClassObject parentClass, string methodName, Call callInInit,
  FunctionObject subclassMethod, FunctionObject parentMethod
where
  // Verify existence of parent class initializer containing a self-method call
  exists(FunctionObject initializer, SelfAttribute selfAttr |
    // Locate parent class __init__ method
    parentClass.declaredAttribute("__init__") = initializer and
    // Ensure call occurs within initializer scope
    callInInit.getScope() = initializer.getFunction() and
    // Confirm call targets self attribute
    callInInit.getFunc() = selfAttr and
    // Match attribute name to target method
    selfAttr.getName() = methodName and
    // Retrieve parent class method definition
    parentMethod = parentClass.declaredAttribute(methodName) and
    // Detect overriding implementation in subclass
    subclassMethod.overrides(parentMethod)
  )
// Report problematic call with contextual method details
select callInInit, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName,
  subclassMethod, subclassMethod.descriptiveString()