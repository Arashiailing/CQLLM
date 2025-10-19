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

// Enhanced predicate to detect descriptor mutation within accessor methods
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore attrStore) {
  // Verify the class implements the descriptor protocol
  descriptorClass.isDescriptorType() and
  // Identify accessor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorAccessor |
    exists(string accessorMethodName |
      // Check standard descriptor method names
      (accessorMethodName = "__get__" or 
       accessorMethodName = "__set__" or 
       accessorMethodName = "__delete__") and
      // Ensure the class contains this accessor method
      descriptorClass.lookupAttribute(accessorMethodName) = descriptorAccessor
    ) and
    // Locate mutation methods called by accessors
    exists(PyFunctionObject mutationMethod |
      // Verify mutation method belongs to the descriptor class
      descriptorClass.lookupAttribute(_) = mutationMethod and
      // Confirm mutation method is invoked by the accessor
      descriptorAccessor.getACallee*() = mutationMethod and
      // Exclude initialization methods from mutation analysis
      not mutationMethod.getName() = "__init__" and
      // Ensure attribute mutation occurs within mutation method's scope
      attrStore.getScope() = mutationMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore attrStore
where mutates_descriptor(descriptorClass, attrStore)
select attrStore,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()