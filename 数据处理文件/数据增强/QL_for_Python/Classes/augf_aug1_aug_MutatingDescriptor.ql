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
predicate containsDescriptorMutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify target class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string protocolMethodName |
    // Retrieve descriptor protocol method implementation
    descriptorClass.lookupAttribute(protocolMethodName) = descriptorMethod and
    // Match descriptor protocol method names
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Locate member functions called by descriptor methods
    exists(PyFunctionObject memberFunction |
      // Called function is a member of target class
      descriptorClass.lookupAttribute(_) = memberFunction and
      // Descriptor method directly/indirectly invokes member function
      descriptorMethod.getACallee*() = memberFunction and
      // Exclude initialization method (__init__)
      not memberFunction.getName() = "__init__" and
      // Mutation occurs within member function scope
      mutationOperation.getScope() = memberFunction.getFunction()
    )
  )
}

// Find classes with descriptor mutations and corresponding operations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where containsDescriptorMutation(descriptorClass, mutationOperation)
// Output mutation location, warning message, related class and its name
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()