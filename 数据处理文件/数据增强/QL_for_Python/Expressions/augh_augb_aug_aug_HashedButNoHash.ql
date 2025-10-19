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
 * Identifies unhashable objects used in hashing contexts.
 * Assumes indexing operations with non-sequence/non-numpy array indices involve hashing.
 * Sequences require integer indices (hashable) while numpy arrays may use list indices (unhashable).
 */

// Detects numpy array types through inheritance from numpy.ndarray
predicate numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value has custom __getitem__ implementation or is a numpy array
predicate has_custom_getitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetValue.getClass())
}

// Determines if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode sourceNode) {
  exists(Value objValue | 
    node.pointsTo(objValue, sourceNode) and 
    objValue.getClass() = unhashableClass |
    (
      // Case 1: Class has no __hash__ method
      not unhashableClass.hasAttribute("__hash__") and 
      not unhashableClass.failedInference(_) and 
      unhashableClass.isNewStyle()
    )
    or
    // Case 2: Class explicitly sets __hash__ to None
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Identifies nodes explicitly hashed using the hash() function
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashFuncCall, GlobalVariable hashGlobalVar |
    hashFuncCall.getArg(0) = node and 
    hashFuncCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode sourceNode) {
  is_unhashable(indexNode, unhashableClass, sourceNode) and
  exists(SubscriptNode subscriptExpr | subscriptExpr.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptExpr.getObject().pointsTo(containerValue) and
      not has_custom_getitem(containerValue)
    )
  )
}

/**
 * Holds if `node` is inside a `try` block catching `TypeError`. Example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * Eliminates false positives where unhashable object usage
 * is intentionally handled by catching the resulting TypeError.
 */
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problemNode, ClassValue problemClass, ControlFlowNode sourceNode
where
  not typeerror_is_caught(problemNode) and
  (
    explicitly_hashed(problemNode) and is_unhashable(problemNode, problemClass, sourceNode)
    or
    unhashable_subscript(problemNode, problemClass, sourceNode)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", problemClass, problemClass.getQualifiedName()