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

/**
 * Identifies mutations within descriptor protocol methods.
 * @param descClass - The descriptor class being analyzed.
 * @param selfMutOp - The mutation operation on 'self' attributes.
 */
predicate mutates_descriptor(ClassObject descClass, SelfAttributeStore selfMutOp) {
  // Validate the class implements descriptor protocol
  descClass.isDescriptorType() and
  
  // Find descriptor protocol methods and their callees
  exists(PyFunctionObject descMethod, PyFunctionObject calledFunc |
    // Locate descriptor protocol methods in the class
    exists(string protocolMethod |
      descClass.lookupAttribute(protocolMethod) = descMethod and
      (protocolMethod = "__get__" or 
       protocolMethod = "__set__" or 
       protocolMethod = "__delete__")
    ) and
    
    // Trace function calls from descriptor methods
    descClass.lookupAttribute(_) = calledFunc and
    descMethod.getACallee*() = calledFunc and
    
    // Exclude initialization methods (expected mutations)
    not calledFunc.getName() = "__init__" and
    
    // Ensure mutation occurs within the traced function scope
    selfMutOp.getScope() = calledFunc.getFunction()
  )
}

// Identify classes with mutations in descriptor methods
from ClassObject descClass, SelfAttributeStore selfMutOp
where mutates_descriptor(descClass, selfMutOp)
select selfMutOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()