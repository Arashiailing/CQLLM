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
// Mutations must occur in non-initializer functions called through descriptor protocol methods
predicate contains_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify target class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  
  // Locate descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = protocolMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    
    // Find functions invoked by descriptor methods
    exists(PyFunctionObject invokedFunction |
      // Invoked function must be a class member method
      descriptorClass.lookupAttribute(_) = invokedFunction and
      
      // Descriptor method directly/indirectly invokes the function
      protocolMethod.getACallee*() = invokedFunction and
      
      // Exclude initialization methods
      not invokedFunction.getName() = "__init__" and
      
      // Mutation occurs within invoked function's scope
      mutationOperation.getScope() = invokedFunction.getFunction()
    )
  )
}

// Retrieve all classes and operations with descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where contains_descriptor_mutation(descriptorClass, mutationOperation)
// Output mutation location, warning message, related class and its name
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()