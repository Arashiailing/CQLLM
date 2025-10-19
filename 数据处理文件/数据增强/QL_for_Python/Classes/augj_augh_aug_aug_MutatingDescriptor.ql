/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects can be shared across many instances. Mutating them can cause strange side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes where mutation operations occur within protocol methods
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutatingOperation) {
  // Confirm the class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Locate descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = protocolMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Trace method invocations from protocol methods
    exists(PyFunctionObject invokedMethod |
      // Ensure called method belongs to the same descriptor class
      descriptorClass.lookupAttribute(_) = invokedMethod and
      // Follow call graph from protocol method to invoked method
      protocolMethod.getACallee*() = invokedMethod and
      // Exclude initialization methods from consideration
      not invokedMethod.getName() = "__init__" and
      // Verify mutation occurs within the invoked method's scope
      mutatingOperation.getScope() = invokedMethod.getFunction()
    )
  )
}

// Find classes and mutation operations violating descriptor immutability
from ClassObject descriptorClass, SelfAttributeStore mutatingOperation
where has_descriptor_mutation(descriptorClass, mutatingOperation)
// Report mutation location with contextual warning and class information
select mutatingOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()