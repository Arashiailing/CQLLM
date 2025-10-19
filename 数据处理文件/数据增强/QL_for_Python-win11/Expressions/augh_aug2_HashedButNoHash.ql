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
 * This assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int, which are hashable, so we don't need to treat them specially.
 * For numpy arrays, the index may be a list, which are not hashable and needs to be treated specially.
 */

// Identifies classes inheriting from numpy.ndarray or numpy.core.ndarray
predicate numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue npModule | npModule.getName() = "numpy" or npModule.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = npModule.attr("ndarray")
  )
}

// Checks if a value has custom __getitem__ implementation (including numpy arrays)
predicate has_custom_getitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetValue.getClass())
}

// Identifies nodes passed as arguments to built-in hash() function
predicate explicitly_hashed(ControlFlowNode targetNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = targetNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Detects unhashable objects used as subscripts in non-custom containers
predicate unhashable_subscript(ControlFlowNode indexExpr, ClassValue unhashableType, ControlFlowNode originNode) {
  is_unhashable(indexExpr, unhashableType, originNode) and
  exists(SubscriptNode subscriptOperation | subscriptOperation.getIndex() = indexExpr |
    exists(Value containerObject |
      subscriptOperation.getObject().pointsTo(containerObject) and
      not has_custom_getitem(containerObject)
    )
  )
}

// Determines if a node points to an unhashable class (no __hash__ or __hash__=None)
predicate is_unhashable(ControlFlowNode targetNode, ClassValue unhashableType, ControlFlowNode originNode) {
  exists(Value pointedValue | targetNode.pointsTo(pointedValue, originNode) and pointedValue.getClass() = unhashableType |
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Holds if `node` is inside a `try` that catches `TypeError`. For example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * This predicate is used to eliminate false positive results. If `hash`
 * is called on an unhashable object then a `TypeError` will be thrown.
 * But this is not a bug if the code catches the `TypeError` and handles
 * it.
 */
// Checks if a node is within a try block catching TypeError
predicate typeerror_is_caught(ControlFlowNode targetNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(targetNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query detecting unhandled unhashable operations
from ControlFlowNode targetNode, ClassValue unhashableType, ControlFlowNode originNode
where
  not typeerror_is_caught(targetNode) and
  (
    explicitly_hashed(targetNode) and is_unhashable(targetNode, unhashableType, originNode)
    or
    unhashable_subscript(targetNode, unhashableType, originNode)
  )
select targetNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableType, unhashableType.getQualifiedName()