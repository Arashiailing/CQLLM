/**
 * @name Unhashable object hashed
 * @description Detects usage of unhashable objects in hashing contexts which causes runtime TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/hash-unhashable-value
 */

import python

/* 
 * Identifies cases where unhashable objects are used in hashing operations.
 * Assumes subscript indexing with non-sequence/non-numpy indices involves hashing.
 * Sequences require integer indices (hashable) while numpy arrays may use list indices (unhashable).
 */

// Determines if a class represents a numpy array type through inheritance from numpy.ndarray
predicate isNumpyArrayType(ClassValue targetClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    targetClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a container has custom __getitem__ implementation or is a numpy array
predicate hasCustomGetitem(Value containerValue) {
  containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(containerValue.getClass())
}

// Identifies unhashable objects by examining their __hash__ attribute
predicate isUnhashableObject(ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode origin) {
  exists(Value targetValue | 
    node.pointsTo(targetValue, origin) and 
    targetValue.getClass() = unhashableClass |
    (
      // Case 1: No __hash__ attribute defined
      not unhashableClass.hasAttribute("__hash__") and 
      not unhashableClass.failedInference(_) and 
      unhashableClass.isNewStyle()
    )
    or
    // Case 2: __hash__ explicitly set to None
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Detects explicit hashing operations using the hash() function
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Finds subscript operations using unhashable index objects
predicate isUnhashableSubscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode origin) {
  isUnhashableObject(indexNode, unhashableClass, origin) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not hasCustomGetitem(containerValue)
    )
  )
}

/**
 * Holds if `node` is inside a `try` block that catches `TypeError`. For example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * This predicate eliminates false positives where hashing an unhashable object
 * is intentionally handled by catching the resulting TypeError.
 */
predicate isTypeErrorCaught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Identifies unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problematicNode, ClassValue problematicClass, ControlFlowNode originNode
where
  not isTypeErrorCaught(problematicNode) and
  (
    isExplicitlyHashed(problematicNode) and isUnhashableObject(problematicNode, problematicClass, originNode)
    or
    isUnhashableSubscript(problematicNode, problematicClass, originNode)
  )
select problematicNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", problematicClass, problematicClass.getQualifiedName()