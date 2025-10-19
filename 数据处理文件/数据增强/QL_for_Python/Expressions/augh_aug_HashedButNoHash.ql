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
 * It assumes indexing operations require hashable keys except for sequences (which use integer indices)
 * and numpy arrays (which may use non-hashable list indices).
 */

// Identifies numpy array types by checking inheritance from numpy.ndarray
predicate numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Determines if a value implements custom indexing behavior via __getitem__
predicate has_custom_getitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(value.getClass())
}

// Detects explicit hash() function calls on values
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashCallNode, GlobalVariable hashGlobalVar |
    hashCallNode.getArg(0) = cfNode and 
    hashCallNode.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Identifies subscript operations using unhashable indices
predicate unhashable_subscript(ControlFlowNode indexCfNode, ClassValue unhashableCls, ControlFlowNode originCfNode) {
  is_unhashable(indexCfNode, unhashableCls, originCfNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexCfNode |
    exists(Value targetVal |
      subscriptNode.getObject().pointsTo(targetVal) and
      not has_custom_getitem(targetVal)
    )
  )
}

// Checks if an object is unhashable by examining its __hash__ implementation
predicate is_unhashable(ControlFlowNode cfNode, ClassValue targetCls, ControlFlowNode originCfNode) {
  exists(Value value | 
    cfNode.pointsTo(value, originCfNode) and 
    value.getClass() = targetCls |
    (
      not targetCls.hasAttribute("__hash__") and 
      not targetCls.failedInference(_) and 
      targetCls.isNewStyle()
    )
    or
    targetCls.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Identifies nodes within try blocks that catch TypeError exceptions.
 * Used to filter false positives where TypeError is intentionally handled.
 * Example:
 *   try:
 *       ... node ...
 *   except TypeError:
 *       ...
 */
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query finding unhandled unhashable object usage
from ControlFlowNode problemCfNode, ClassValue problemCls, ControlFlowNode originCfNode
where
  not typeerror_is_caught(problemCfNode) and
  (
    explicitly_hashed(problemCfNode) and is_unhashable(problemCfNode, problemCls, originCfNode)
    or
    unhashable_subscript(problemCfNode, problemCls, originCfNode)
  )
select problemCfNode.getNode(), "This $@ of $@ is unhashable.", originCfNode, "instance", problemCls, problemCls.getQualifiedName()