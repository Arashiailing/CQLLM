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

// Detects descriptor mutation within accessor methods by analyzing method calls and attribute modifications
predicate mutates_descriptor(ClassObject descriptorType, SelfAttributeStore attributeMutation) {
  // Validate class implements descriptor protocol
  descriptorType.isDescriptorType() and
  // Identify descriptor accessor methods (__get__/__/__set__/__delete__)
  exists(PyFunctionObject accessorMethod |
    exists(string methodName |
      // Check standard descriptor method names
      (methodName = "__get__" or 
       methodName = "__set__" or 
       methodName = "__delete__") and
      // Confirm class contains this accessor method
      descriptorType.lookupAttribute(methodName) = accessorMethod
    ) and
    // Locate mutation methods invoked by accessors
    exists(PyFunctionObject mutatingMethod |
      // Verify mutation method belongs to descriptor class
      descriptorType.lookupAttribute(_) = mutatingMethod and
      // Confirm mutation method is called by accessor
      accessorMethod.getACallee*() = mutatingMethod and
      // Exclude initialization methods from analysis
      not mutatingMethod.getName() = "__init__" and
      // Ensure attribute mutation occurs within mutation method scope
      attributeMutation.getScope() = mutatingMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descriptorType, SelfAttributeStore attributeMutation
where mutates_descriptor(descriptorType, attributeMutation)
select attributeMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorType, descriptorType.getName()