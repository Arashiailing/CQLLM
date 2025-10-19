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

// Detects descriptor mutations within accessor methods
predicate hasDescriptorMutation(ClassObject descriptorClass, SelfAttributeStore attributeAssignment) {
  // Identify classes implementing descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor accessor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorAccessor |
    exists(string methodName |
      (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
      descriptorClass.lookupAttribute(methodName) = descriptorAccessor
    ) and
    // Locate mutating methods called by accessors
    exists(PyFunctionObject mutationMethod |
      // Ensure method belongs to descriptor class
      descriptorClass.lookupAttribute(_) = mutationMethod and
      // Verify method is invoked by accessor
      descriptorAccessor.getACallee*() = mutationMethod and
      // Exclude initialization methods
      not mutationMethod.getName() = "__init__" and
      // Confirm mutation occurs within method scope
      attributeAssignment.getScope() = mutationMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore attributeAssignment
where hasDescriptorMutation(descriptorClass, attributeAssignment)
select attributeAssignment,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()