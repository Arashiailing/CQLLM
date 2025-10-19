/**
 * @name Unhashable object hashed
 * @description Hashing an object which is not hashable will result in a TypeError at runtime.
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
 * This analysis assumes indexing operations involve hashing when:
 * 1. The container is not a sequence (which requires integer indices)
 * 2. The container is not a numpy array (which allows list indices)
 * Other container types require hashable indices for proper operation.
 */

// Identifies numpy array classes through inheritance from numpy.ndarray
predicate isNumpyArrayType(ClassValue numpyClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a container has custom indexing behavior
predicate hasCustomGetitem(Value containerValue) {
  containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(containerValue.getClass())
}

// Detects direct hashing operations using built-in hash()
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Finds unhashable values used as indices in standard containers
predicate isUnhashableSubscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode origin) {
  isUnhashable(indexNode, unhashableClass, origin) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value container |
      subscriptNode.getObject().pointsTo(container) and
      not hasCustomGetitem(container)
    )
  )
}

// Determines if a value belongs to an unhashable class
predicate isUnhashable(ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode origin) {
  exists(Value value | node.pointsTo(value, origin) and value.getClass() = unhashableClass |
    (not unhashableClass.hasAttribute("__hash__") and 
     not unhashableClass.failedInference(_) and 
     unhashableClass.isNewStyle())
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Identifies nodes protected by TypeError handlers. For example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * This reduces false positives by excluding cases where potential
 * TypeErrors from unhashable operations are explicitly handled.
 */
predicate isTypeErrorCaught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main detection logic for unhandled unhashable operations
from ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode origin
where
  not isTypeErrorCaught(node) and
  (
    isExplicitlyHashed(node) and isUnhashable(node, unhashableClass, origin)
    or
    isUnhashableSubscript(node, unhashableClass, origin)
  )
select node.getNode(), "This $@ of $@ is unhashable.", origin, "instance", unhashableClass, unhashableClass.getQualifiedName()