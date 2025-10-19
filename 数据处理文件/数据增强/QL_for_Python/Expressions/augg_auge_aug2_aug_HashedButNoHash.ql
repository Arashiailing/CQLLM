/**
 * @name Unhashable object hashed
 * @description Detects unhashable objects used in hashing contexts which cause runtime TypeErrors.
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
 * Identifies unhashable objects in hashing contexts. Assumes indexing operations
 * with non-sequence/non-numpy indices involve hashing. Sequences use integer indices
 * (hashable) and numpy arrays require special handling due to list indices.
 */

// Core predicate to identify unhashable objects
predicate is_unhashable_object(ControlFlowNode node, ClassValue unhashableType, ControlFlowNode sourceNode) {
  exists(Value value | node.pointsTo(value, sourceNode) and value.getClass() = unhashableType |
    // Case 1: Class lacks __hash__ implementation
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    // Case 2: Class explicitly sets __hash__ to None
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Identifies numpy array types through inheritance from numpy.ndarray
predicate is_numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a container has custom __getitem__ implementation
predicate has_custom_getitem_method(Value containerValue) {
  containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(containerValue.getClass())
}

// Detects explicit hash() function calls
predicate is_explicitly_hashed(ControlFlowNode node) {
  exists(CallNode callNode, GlobalVariable globalVar |
    callNode.getArg(0) = node and 
    callNode.getFunction().(NameNode).uses(globalVar) and 
    globalVar.getId() = "hash"
  )
}

// Checks if subscript operation uses unhashable index
predicate uses_unhashable_index(ControlFlowNode indexNode, ClassValue unhashableType, ControlFlowNode sourceNode) {
  is_unhashable_object(indexNode, unhashableType, sourceNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not has_custom_getitem_method(containerValue)
    )
  )
}

/**
 * Identifies nodes protected by TypeError-catching try blocks.
 * Reduces false positives by excluding cases where:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 * Since unhashable operations throw TypeError, explicit handling indicates intentional behavior.
 */
predicate is_inside_typeerror_handler(ControlFlowNode node) {
  exists(Try tryNode |
    tryNode.getBody().contains(node.getNode()) and
    tryNode.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable operations
from ControlFlowNode problemNode, ClassValue problemType, ControlFlowNode sourceNode
where
  not is_inside_typeerror_handler(problemNode) and
  (
    (is_explicitly_hashed(problemNode) and is_unhashable_object(problemNode, problemType, sourceNode))
    or
    uses_unhashable_index(problemNode, problemType, sourceNode)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", problemType, problemType.getQualifiedName()