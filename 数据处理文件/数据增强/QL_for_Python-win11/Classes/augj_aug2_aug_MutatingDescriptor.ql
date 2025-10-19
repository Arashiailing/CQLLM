/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects can be shared across many instances. Mutating them can cause strange side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor */

import python

from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where 
  // Verify the target class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Identify descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = protocolMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Locate functions invoked by descriptor methods
    exists(PyFunctionObject invokedFunction |
      // Ensure invoked function is a class member
      descriptorClass.lookupAttribute(_) = invokedFunction and
      // Verify direct/indirect invocation from descriptor method
      protocolMethod.getACallee*() = invokedFunction and
      // Exclude initialization methods
      not invokedFunction.getName() = "__init__" and
      // Confirm mutation occurs within invoked function's scope
      mutationOperation.getScope() = invokedFunction.getFunction()
    )
  )
// Output mutation location, warning message, and related class details
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()