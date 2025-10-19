/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects are shared across many instances. Mutating them can cause side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

/**
 * Detects descriptor classes that contain mutation operations
 * within their descriptor protocol methods or methods called by them.
 * 
 * @param descriptorClass The class implementing the descriptor protocol
 * @param mutationOperation The mutation operation found in the descriptor
 */
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify that the class implements the descriptor protocol
  descriptorClass.isDescriptorType() and
  
  // Check for descriptor protocol methods (__get__, __set__, __delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = protocolMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    
    // Follow the call chain to find methods that might perform mutations
    exists(PyFunctionObject calledMethod |
      // The called method belongs to the same descriptor class
      descriptorClass.lookupAttribute(_) = calledMethod and
      
      // There is a call relationship from the descriptor protocol method
      protocolMethod.getACallee*() = calledMethod and
      
      // Exclude initialization methods as they are expected to modify state
      not calledMethod.getName() = "__init__" and
      
      // The mutation operation occurs within the called method's scope
      mutationOperation.getScope() = calledMethod.getFunction()
    )
  )
}

// Find all descriptor classes with mutation operations and their locations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorClass, mutationOperation)
// Report the mutation location with a contextual warning message
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()