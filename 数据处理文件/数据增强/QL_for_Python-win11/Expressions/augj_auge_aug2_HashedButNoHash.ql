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
 * This analysis identifies unhashable objects used in hashing contexts.
 * We consider that any indexing operation where the container is not a sequence or numpy array involves hashing.
 * Sequences (like lists) require integer indices (which are hashable), so they are excluded.
 * Numpy arrays are special because they may use lists as indices (which are unhashable), so we handle them separately.
 */

// Holds if the given class is a numpy array type, i.e., it inherits from numpy.ndarray or numpy.core.ndarray.
predicate numpy_array_type(ClassValue ndarrayType) {
  exists(ModuleValue numpyModule | 
    (numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core") and
    ndarrayType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Holds if the value has a custom __getitem__ method (including numpy arrays, which are handled by numpy_array_type).
predicate has_custom_getitem(Value targetVal) {
  targetVal.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetVal.getClass())
}

// Holds if the control flow node is the argument to the built-in hash() function (explicit hashing).
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashFuncCall, GlobalVariable hashGlobalVar |
    hashFuncCall.getArg(0) = cfNode and 
    hashFuncCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Holds if the index node is an unhashable object and is used in a subscript operation where the container does not have a custom __getitem__ method.
predicate unhashable_subscript(ControlFlowNode idxNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  is_unhashable(idxNode, unhashableCls, originNode) and
  exists(SubscriptNode subscriptExpr | subscriptExpr.getIndex() = idxNode |
    exists(Value containerVal |
      subscriptExpr.getObject().pointsTo(containerVal) and
      not has_custom_getitem(containerVal)
    )
  )
}

// Holds if the control flow node points to a value of an unhashable class (either the class has no __hash__ method or it is set to None).
predicate is_unhashable(ControlFlowNode cfNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  exists(Value targetVal | 
    cfNode.pointsTo(targetVal, originNode) and 
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
 * Holds if the control flow node is within a try block that catches TypeError. This helps eliminate false positives where unhashable operations are handled intentionally.
 *
 * For example:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 */
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable objects in hashing or subscript contexts
from ControlFlowNode cfNode, ClassValue unhashableCls, ControlFlowNode originNode
where
  not typeerror_is_caught(cfNode) and
  (
    (explicitly_hashed(cfNode) and is_unhashable(cfNode, unhashableCls, originNode))
    or
    unhashable_subscript(cfNode, unhashableCls, originNode)
  )
select cfNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableCls, unhashableCls.getQualifiedName()