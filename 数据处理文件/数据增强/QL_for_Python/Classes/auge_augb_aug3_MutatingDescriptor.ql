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

// Predicate identifying descriptor classes with mutable accessors
predicate mutates_descriptor(ClassObject descriptorType, SelfAttributeStore selfAttrMutation) {
  // Verify the class implements descriptor protocol
  descriptorType.isDescriptorType() and
  
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject accessorMethod, string methodName |
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    descriptorType.lookupAttribute(methodName) = accessorMethod and
    
    // Locate mutation methods called by accessors
    exists(PyFunctionObject mutatorMethod |
      // Mutation method belongs to descriptor class
      descriptorType.lookupAttribute(_) = mutatorMethod and
      // Exclude initialization methods from analysis
      not mutatorMethod.getName() = "__init__" and
      // Mutation method is invoked by descriptor accessor
      accessorMethod.getACallee*() = mutatorMethod and
      // Attribute mutation occurs within mutation method's scope
      selfAttrMutation.getScope() = mutatorMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descriptorType, SelfAttributeStore selfAttrMutation
where mutates_descriptor(descriptorType, selfAttrMutation)
select selfAttrMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorType, descriptorType.getName()