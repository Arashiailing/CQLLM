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

// Identifies descriptor classes containing mutation operations within their protocol methods
predicate descriptorClassHasMutationOperation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Ensure the class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = descriptorMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Locate methods invoked by descriptor protocol methods
    exists(PyFunctionObject invokedMethod |
      // Invoked method belongs to the same descriptor class
      descriptorClass.lookupAttribute(_) = invokedMethod and
      // Trace call chain from descriptor method to invoked method
      descriptorMethod.getACallee*() = invokedMethod and
      // Exclude initialization methods from consideration
      not invokedMethod.getName() = "__init__" and
      // Mutation operation occurs within the invoked method's scope
      mutationOperation.getScope() = invokedMethod.getFunction()
    )
  )
}

// Identify classes and operations where descriptor mutation occurs
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where descriptorClassHasMutationOperation(descriptorClass, mutationOperation)
// Output mutation location, warning message, and related class details
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()