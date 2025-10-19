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
predicate isNumpyArrayType(ClassValue arrayCls) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    arrayCls.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Checks if a container has custom __getitem__ implementation or is a numpy array
predicate hasCustomGetitem(Value containerVal) {
  containerVal.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(containerVal.getClass())
}

// Identifies unhashable objects by examining their __hash__ attribute
predicate isUnhashableObject(ControlFlowNode node, ClassValue unhashableCls, ControlFlowNode origin) {
  exists(Value val | 
    node.pointsTo(val, origin) and 
    val.getClass() = unhashableCls |
    (
      // Case 1: No __hash__ attribute defined
      not unhashableCls.hasAttribute("__hash__") and 
      not unhashableCls.failedInference(_) and 
      unhashableCls.isNewStyle()
    )
    or
    // Case 2: __hash__ explicitly set to None
    unhashableCls.lookup("__hash__") = Value::named("None")
  )
}

// Detects explicit hashing operations using the hash() function
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode callNode, GlobalVariable hashGlobal |
    callNode.getArg(0) = node and 
    callNode.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Finds subscript operations using unhashable index objects
predicate isUnhashableSubscript(ControlFlowNode idxNode, ClassValue unhashableCls, ControlFlowNode origin) {
  isUnhashableObject(idxNode, unhashableCls, origin) and
  exists(SubscriptNode subscrNode | subscrNode.getIndex() = idxNode |
    exists(Value containerVal |
      subscrNode.getObject().pointsTo(containerVal) and
      not hasCustomGetitem(containerVal)
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
  exists(Try tryStmt |
    tryStmt.getBody().contains(node.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Identifies unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problemNode, ClassValue problemCls, ControlFlowNode originNode
where
  not isTypeErrorCaught(problemNode) and
  (
    isExplicitlyHashed(problemNode) and isUnhashableObject(problemNode, problemCls, originNode)
    or
    isUnhashableSubscript(problemNode, problemCls, originNode)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", problemCls, problemCls.getQualifiedName()