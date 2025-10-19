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

// Identify classes implementing descriptor protocol that contain mutation operations
predicate containsDescriptorMutation(ClassObject descriptorImplClass, SelfAttributeStore mutatingOperation) {
  // Verify target class implements descriptor protocol
  descriptorImplClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    // Retrieve descriptor protocol method implementation
    descriptorImplClass.lookupAttribute(methodName) = protocolMethod and
    // Match descriptor protocol method names
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Locate member functions called by descriptor methods
    exists(PyFunctionObject classMethod |
      // Called function is a member of target class
      descriptorImplClass.lookupAttribute(_) = classMethod and
      // Descriptor method directly/indirectly invokes member function
      protocolMethod.getACallee*() = classMethod and
      // Exclude initialization method (__init__)
      not classMethod.getName() = "__init__" and
      // Mutation occurs within member function scope
      mutatingOperation.getScope() = classMethod.getFunction()
    )
  )
}

// Find classes with descriptor mutations and corresponding operations
from ClassObject descriptorImplClass, SelfAttributeStore mutatingOperation
where containsDescriptorMutation(descriptorImplClass, mutatingOperation)
// Output mutation location, warning message, related class and its name
select mutatingOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorImplClass, descriptorImplClass.getName()