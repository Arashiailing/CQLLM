/**
 * @name Unhashable object hashed
 * @description Hashing an object that is not hashable will cause a TypeError at runtime.
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
 * Analysis assumes indexing operations involve hashing when:
 * - Value is not a sequence (sequences require integer indices which are hashable)
 * - Value is not a numpy array (numpy arrays may use unhashable list indices)
 */

// Identifies numpy array types through inheritance from numpy.ndarray
predicate numpy_array_type(ClassValue arrayCls) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    arrayCls.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Determines if a value has custom __getitem__ or is a numpy array
predicate has_custom_getitem(Value val) {
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(val.getClass())
}

// Checks if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableCls, ControlFlowNode srcNode) {
  exists(Value value | 
    node.pointsTo(value, srcNode) and 
    value.getClass() = unhashableCls |
    (
      not unhashableCls.hasAttribute("__hash__") and 
      not unhashableCls.failedInference(_) and 
      unhashableCls.isNewStyle()
    )
    or
    unhashableCls.lookup("__hash__") = Value::named("None")
  )
}

// Identifies nodes explicitly hashed using hash() function
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode srcNode) {
  is_unhashable(indexNode, unhashableCls, srcNode) and
  exists(SubscriptNode subscript | subscript.getIndex() = indexNode |
    exists(Value targetVal |
      subscript.getObject().pointsTo(targetVal) and
      not has_custom_getitem(targetVal)
    )
  )
}

/**
 * Holds if `node` is inside a `try` block catching `TypeError`. Example:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 * Eliminates false positives where unhashable object hashing
 * is intentionally handled by catching the resulting TypeError.
 */
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problemNode, ClassValue unhashableCls, ControlFlowNode srcNode
where
  not typeerror_is_caught(problemNode) and
  (
    explicitly_hashed(problemNode) and is_unhashable(problemNode, unhashableCls, srcNode)
    or
    unhashable_subscript(problemNode, unhashableCls, srcNode)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", srcNode, "instance", unhashableCls, unhashableCls.getQualifiedName()