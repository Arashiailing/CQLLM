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

// Predicate to detect descriptor mutation within accessor methods
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore attrStore) {
  // Verify the class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Identify accessor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject accessorMethod |
    exists(string methodName |
      (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
      descriptorClass.lookupAttribute(methodName) = accessorMethod
    ) and
    // Locate mutating functions called by accessors
    exists(PyFunctionObject mutatingFunc |
      // Ensure mutatingFunc belongs to descriptor class
      descriptorClass.lookupAttribute(_) = mutatingFunc and
      // Verify mutatingFunc is invoked by accessor
      accessorMethod.getACallee*() = mutatingFunc and
      // Exclude initialization methods
      not mutatingFunc.getName() = "__init__" and
      // Confirm mutation occurs within mutatingFunc's scope
      attrStore.getScope() = mutatingFunc.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore attrStore
where mutates_descriptor(descriptorClass, attrStore)
select attrStore,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()