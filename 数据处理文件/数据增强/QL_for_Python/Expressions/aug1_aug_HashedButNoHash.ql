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
 * This query identifies unhashable objects used in hashing contexts.
 * Hashing contexts include:
 * 1. Explicit calls to hash() function
 * 2. Subscript operations on non-sequence/non-numpy objects
 * 
 * The detection assumes:
 * - Sequences require integer indices (always hashable)
 * - NumPy arrays may use non-hashable indices (like lists)
 * - Objects are unhashable if they lack __hash__ or have __hash__ = None
 */

// Identifies classes representing NumPy array types
predicate is_numpy_array_type(ClassValue arrayType) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    arrayType.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Checks if a value has custom __getitem__ implementation
predicate has_custom_getitem_method(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(value.getClass())
}

// Detects nodes passed as argument to hash() function
predicate is_explicitly_hashed(ControlFlowNode targetNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobalVar |
    hashCall.getArg(0) = targetNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Identifies subscript operations with unhashable indices
predicate has_unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  is_unhashable_object(indexNode, unhashableCls, originNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value targetVal |
      subscriptNode.getObject().pointsTo(targetVal) and
      not has_custom_getitem_method(targetVal)
    )
  )
}

// Determines if an object is unhashable
predicate is_unhashable_object(ControlFlowNode node, ClassValue cls, ControlFlowNode originNode) {
  exists(Value value | node.pointsTo(value, originNode) and value.getClass() = cls |
    (not cls.hasAttribute("__hash__") and 
     not cls.failedInference(_) and 
     cls.isNewStyle())
    or
    cls.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Holds if `node` is inside a `try` block catching `TypeError`.
 * This predicate eliminates false positives where TypeError is
 * intentionally caught and handled.
 */
predicate is_inside_typeerror_handler(ControlFlowNode node) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(node.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable objects in hashing contexts
from ControlFlowNode problematicNode, ClassValue unhashableCls, ControlFlowNode originNode
where
  not is_inside_typeerror_handler(problematicNode) and
  (
    (is_explicitly_hashed(problematicNode) and is_unhashable_object(problematicNode, unhashableCls, originNode))
    or
    has_unhashable_subscript(problematicNode, unhashableCls, originNode)
  )
select problematicNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableCls, unhashableCls.getQualifiedName()