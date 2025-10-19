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

// Checks if a class inherits from numpy.ndarray or numpy.core.ndarray
predicate is_numpy_array_type(ClassValue numpyArrayClass) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    numpyArrayClass.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Determines if a value implements custom __getitem__ (including numpy arrays)
predicate has_custom_getitem_method(Value targetVal) {
  targetVal.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(targetVal.getClass())
}

// Finds arguments passed to built-in hash() function (explicit hashing)
predicate is_explicitly_hashed(ControlFlowNode nodeToHash) {
  exists(CallNode hashFuncCall, GlobalVariable hashGlobalVar |
    hashFuncCall.getArg(0) = nodeToHash and 
    hashFuncCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Detects unhashable indices in subscript operations where container lacks custom __getitem__
predicate is_unhashable_subscript(ControlFlowNode indexExpr, ClassValue unhashableCls, ControlFlowNode origin) {
  is_unhashable_value(indexExpr, unhashableCls, origin) and
  exists(SubscriptNode subscriptExpr | subscriptExpr.getIndex() = indexExpr |
    exists(Value containerVal |
      subscriptExpr.getObject().pointsTo(containerVal) and
      not has_custom_getitem_method(containerVal)
    )
  )
}

// Checks if a node points to an unhashable class (no __hash__ or __hash__=None)
predicate is_unhashable_value(ControlFlowNode exprNode, ClassValue unhashableCls, ControlFlowNode origin) {
  exists(Value targetVal | 
    exprNode.pointsTo(targetVal, origin) and 
    targetVal.getClass() = unhashableCls and
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
 * Holds if `exprNode` is inside a try block catching TypeError. Example:
 *
 *    try:
 *       ... exprNode ...
 *    except TypeError:
 *       ...
 *
 * Excludes intentionally handled unhashable operations.
 */
predicate is_typeerror_caught(ControlFlowNode exprNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(exprNode.getNode()) and
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