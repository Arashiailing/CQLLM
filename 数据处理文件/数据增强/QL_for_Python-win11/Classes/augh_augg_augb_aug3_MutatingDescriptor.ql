/**
 * @name Descriptor mutation in accessor methods
 * @description Identifies mutations of descriptor objects within __get__, __set__, or __delete__ methods. 
 *              Such mutations can cause unexpected side effects since descriptors are shared across instances.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

/* This predicate identifies descriptor mutations by examining method calls and attribute modifications
   within descriptor accessor methods. It checks if a class implements the descriptor protocol and
   detects any mutations that occur within methods called by the descriptor accessors. */
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore attributeModification) {
  // Ensure the class implements the descriptor protocol
  descriptorClass.isDescriptorType() and
  
  // Find descriptor accessor methods (__get__, __set__, or __delete__)
  exists(PyFunctionObject accessorFunc, string accessorName |
    // Standard descriptor method names
    (accessorName = "__get__" or 
     accessorName = "__set__" or 
     accessorName = "__delete__") and
    // Verify the class has this accessor method
    descriptorClass.lookupAttribute(accessorName) = accessorFunc and
    
    // Identify methods that mutate the descriptor and are called by accessors
    exists(PyFunctionObject mutationFunc |
      // Confirm the mutation method belongs to the descriptor class
      descriptorClass.lookupAttribute(_) = mutationFunc and
      // Check if the accessor method calls the mutation method
      accessorFunc.getACallee*() = mutationFunc and
      // Exclude initialization methods from consideration
      not mutationFunc.getName() = "__init__" and
      // Ensure the attribute modification occurs within the mutation method
      attributeModification.getScope() = mutationFunc.getFunction()
    )
  )
}

// Main query to find descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore attributeModification
where mutates_descriptor(descriptorClass, attributeModification)
select attributeModification,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()