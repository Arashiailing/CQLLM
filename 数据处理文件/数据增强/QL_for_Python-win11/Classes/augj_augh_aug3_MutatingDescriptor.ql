/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Detects unsafe mutations within descriptor protocol methods. Shared descriptor objects can cause side effects or race conditions when mutated.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor mutations by analyzing:
// - Classes implementing descriptor protocol
// - Protocol methods (__get__/__set__/__delete__)
// - Mutating functions called by protocol methods
// - Attribute stores within mutating functions' scope
predicate has_descriptor_mutation(ClassObject descriptorImpl, SelfAttributeStore attributeMutation) {
  // Validate descriptor protocol implementation
  descriptorImpl.isDescriptorType() and
  // Find protocol methods and associated mutating functions
  exists(PyFunctionObject protocolMethod, string descriptorMethod, PyFunctionObject mutationFunc |
    // Identify descriptor protocol methods
    (descriptorMethod = "__get__" or descriptorMethod = "__set__" or descriptorMethod = "__delete__") and
    // Link protocol method to descriptor class
    descriptorImpl.lookupAttribute(descriptorMethod) = protocolMethod and
    // Locate mutating functions in descriptor class
    descriptorImpl.lookupAttribute(_) = mutationFunc and
    // Verify mutation function is called by protocol method
    protocolMethod.getACallee*() = mutationFunc and
    // Exclude initialization methods from analysis
    not mutationFunc.getName() = "__init__" and
    // Confirm attribute mutation occurs in mutation function's scope
    attributeMutation.getScope() = mutationFunc.getFunction()
  )
}

// Query for descriptor mutation instances
from ClassObject descriptorImpl, SelfAttributeStore attributeMutation
where has_descriptor_mutation(descriptorImpl, attributeMutation)
select attributeMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorImpl, descriptorImpl.getName()