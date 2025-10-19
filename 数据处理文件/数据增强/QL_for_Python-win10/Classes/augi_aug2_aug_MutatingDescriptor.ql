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

// Identifies descriptor classes containing mutation operations
// Mutations must occur in non-initializer functions called via descriptor protocol methods
predicate containsDescriptorMutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify the class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string protocolMethodName |
    descriptorClass.lookupAttribute(protocolMethodName) = descriptorMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Locate functions invoked by descriptor methods
    exists(PyFunctionObject calledFunction |
      // Called function must be a class member method
      descriptorClass.lookupAttribute(_) = calledFunction and
      // Descriptor method directly/indirectly invokes the function
      descriptorMethod.getACallee*() = calledFunction and
      // Exclude initialization methods
      not calledFunction.getName() = "__init__" and
      // Mutation occurs within the called function's scope
      mutationOperation.getScope() = calledFunction.getFunction()
    )
  )
}

// Find all classes with descriptor mutations and associated operations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where containsDescriptorMutation(descriptorClass, mutationOperation)
// Output mutation location, warning message, related class and its name
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()