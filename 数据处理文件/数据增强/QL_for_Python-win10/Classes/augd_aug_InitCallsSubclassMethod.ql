/**
 * @name `__init__` method calls overridden method
 * @description Detects when a method is called from `__init__` that is overridden by a subclass.
 *              This can lead to a partially initialized instance being observed by the overridden method,
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

// Identify cases where a parent class's __init__ method invokes a method that is overridden by a subclass
from
  ClassObject baseClass, string targetMethodName, Call methodInvocation, 
  FunctionObject derivedMethod, FunctionObject baseMethod,
  FunctionObject constructorMethod, SelfAttribute selfReference
where
  // Retrieve the __init__ method of the parent class
  baseClass.declaredAttribute("__init__") = constructorMethod and
  // Confirm the method call occurs within the scope of the __init__ method
  methodInvocation.getScope() = constructorMethod.getFunction() and
  // Ensure the call is to a self attribute
  methodInvocation.getFunc() = selfReference and
  // Verify the self attribute name matches the target method name
  selfReference.getName() = targetMethodName and
  // Obtain the target method as declared in the parent class
  baseMethod = baseClass.declaredAttribute(targetMethodName) and
  // Confirm there exists a subclass that overrides the parent class method
  derivedMethod.overrides(baseMethod)
// Output warning message indicating a call to an overridden method within __init__
select methodInvocation, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseMethod, targetMethodName, derivedMethod, derivedMethod.descriptiveString()