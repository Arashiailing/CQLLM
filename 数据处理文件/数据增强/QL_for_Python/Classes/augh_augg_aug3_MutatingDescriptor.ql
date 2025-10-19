/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Identifies mutations of descriptor objects within their accessor methods (__get__, __set__, or __delete__). 
 *              Descriptor objects are shared across instances, and mutating them can cause unexpected side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor mutations within accessor methods
predicate mutates_descriptor(ClassObject descClass, SelfAttributeStore selfAttrStore) {
  // Verify the class implements descriptor protocol
  descClass.isDescriptorType() and
  // Locate accessor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject accessorMethod |
    exists(string methodName | methodName in ["__get__", "__set__", "__delete__"] |
      descClass.lookupAttribute(methodName) = accessorMethod
    ) and
    // Find mutating methods invoked by accessors
    exists(PyFunctionObject mutatorMethod |
      // Confirm mutatorMethod belongs to descriptor class
      mutatorMethod = descClass.lookupAttribute(_) and
      // Verify mutatorMethod is called by accessor
      accessorMethod.getACallee*() = mutatorMethod and
      // Exclude initialization methods
      mutatorMethod.getName() != "__init__" and
      // Ensure mutation occurs within mutatorMethod's scope
      selfAttrStore.getScope() = mutatorMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descClass, SelfAttributeStore selfAttrStore
where mutates_descriptor(descClass, selfAttrStore)
select selfAttrStore,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()