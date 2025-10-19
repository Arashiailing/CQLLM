/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Detects mutations within descriptor protocol methods that can cause shared state issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes containing mutation operations in protocol methods
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = protocolMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Locate methods invoked by descriptor protocol methods
    exists(PyFunctionObject invokedMethod |
      // Invoked method belongs to the same descriptor class
      descriptorClass.lookupAttribute(_) = invokedMethod and
      // Trace call chain from protocol method to invoked method
      protocolMethod.getACallee*() = invokedMethod and
      // Exclude initialization methods from analysis
      not invokedMethod.getName() = "__init__" and
      // Mutation occurs within the invoked method's scope
      mutationOperation.getScope() = invokedMethod.getFunction()
    )
  )
}

// Identify descriptor classes and their mutation operations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorClass, mutationOperation)
// Output mutation location with warning message and class details
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()