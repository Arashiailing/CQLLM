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
 * This analysis assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int, which are hashable, so they don't require special handling.
 * For numpy arrays, the index may be a list, which are not hashable and needs special treatment.
 */

// Identifies numpy array types by checking inheritance from numpy.ndarray
predicate is_numpy_array_type(ClassValue arrayClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value has custom __getitem__ implementation or is a numpy array
predicate has_custom_getitem_method(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(targetValue.getClass())
}

// Checks if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable_object(ControlFlowNode objNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  exists(Value objectValue | 
    objNode.pointsTo(objectValue, originNode) and 
    objectValue.getClass() = unhashableClass |
    (
      not unhashableClass.hasAttribute("__hash__") and 
      not unhashableClass.failedInference(_) and 
      unhashableClass.isNewStyle()
    )
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Identifies nodes that are explicitly hashed using the hash() function
predicate is_explicitly_hashed(ControlFlowNode hashedNode) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = hashedNode and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate has_unhashable_subscript(ControlFlowNode subscriptIndexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable_object(subscriptIndexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = subscriptIndexNode |
    exists(Value containerValue |
      subscriptOp.getObject().pointsTo(containerValue) and
      not has_custom_getitem_method(containerValue)
    )
  )
}

/**
 * Holds if `targetNode` is inside a `try` block that catches `TypeError`. For example:
 *
 *    try:
 *       ... targetNode ...
 *    except TypeError:
 *       ...
 *
 * This predicate eliminates false positives where hashing an unhashable object
 * is intentionally handled by catching the resulting TypeError.
 */
predicate is_typeerror_caught(ControlFlowNode targetNode) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(targetNode.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query finding unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problematicNode, ClassValue problematicClass, ControlFlowNode originNode
where
  not is_typeerror_caught(problematicNode) and
  (
    is_explicitly_hashed(problematicNode) and is_unhashable_object(problematicNode, problematicClass, originNode)
    or
    has_unhashable_subscript(problematicNode, problematicClass, originNode)
  )
select problematicNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", problematicClass, problematicClass.getQualifiedName()