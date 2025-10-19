/**
 * @name Unhashable object hashed
 * @description Detects runtime TypeError caused by hashing unhashable objects.
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
 * Assumes indexing operations with non-sequence/non-numpy values involve hashing.
 * Sequences use integer indices (hashable), numpy arrays allow list indices (unhashable).
 */

// Determines if a class represents a numpy array type
predicate is_numpy_array_type(ClassValue cls) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    cls.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Checks if a value implements custom __getitem__ (including numpy arrays)
predicate has_custom_getitem_method(Value val) {
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(val.getClass())
}

// Identifies arguments passed to built-in hash() function (explicit hashing)
predicate is_explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Detects unhashable indices in subscript operations where container lacks custom __getitem__
predicate is_unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode origin) {
  is_unhashable_value(indexNode, unhashableCls, origin) and
  exists(SubscriptNode subscript | subscript.getIndex() = indexNode |
    exists(Value container |
      subscript.getObject().pointsTo(container) and
      not has_custom_getitem_method(container)
    )
  )
}

// Checks if a node points to an unhashable class (no __hash__ or __hash__=None)
predicate is_unhashable_value(ControlFlowNode exprNode, ClassValue unhashableCls, ControlFlowNode origin) {
  exists(Value val | 
    exprNode.pointsTo(val, origin) and 
    val.getClass() = unhashableCls and
    (
      (not unhashableCls.hasAttribute("__hash__") and 
       not unhashableCls.failedInference(_) and 
       unhashableCls.isNewStyle())
      or
      unhashableCls.lookup("__hash__") = Value::named("None")
    )
  )
}

/**
 * Holds if `node` is inside a try block catching TypeError. Example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * Excludes intentionally handled unhashable operations.
 */
predicate is_typeerror_caught(ControlFlowNode node) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(node.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable objects in hashing/subscript contexts
from ControlFlowNode problemNode, ClassValue unhashableCls, ControlFlowNode origin
where
  not is_typeerror_caught(problemNode) and
  (
    is_explicitly_hashed(problemNode) and is_unhashable_value(problemNode, unhashableCls, origin)
    or
    is_unhashable_subscript(problemNode, unhashableCls, origin)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", origin, "instance", unhashableCls, unhashableCls.getQualifiedName()