/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects are shared across instances. Mutating them may cause unexpected side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identify classes implementing descriptor protocol and their mutation operations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where 
  // Verify class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor methods and their call chains
  exists(PyFunctionObject descriptorMethod, string protocolMethod, PyFunctionObject invokedFunction |
    // Identify descriptor protocol methods (__get__/__set__/__delete__)
    descriptorClass.lookupAttribute(protocolMethod) = descriptorMethod and
    (protocolMethod = "__get__" or protocolMethod = "__set__" or protocolMethod = "__delete__") and
    // Locate class member functions called by descriptor methods
    descriptorClass.lookupAttribute(_) = invokedFunction and
    // Exclude initialization methods and validate call relationship
    not invokedFunction.getName() = "__init__" and
    descriptorMethod.getACallee*() = invokedFunction and
    // Confirm mutation occurs within invoked function's scope
    mutationOperation.getScope() = invokedFunction.getFunction()
  )
// Output mutation location, warning message, related class and its name
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()