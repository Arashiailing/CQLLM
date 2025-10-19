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

/**
 * Determines if a class represents a numpy array type.
 * Matches classes inheriting from numpy.ndarray or numpy.core.ndarray.
 */
predicate numpy_array_type(ClassValue ndarrayCls) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or 
    numpyModule.getName() = "numpy.core" |
    ndarrayCls.getASuperType() = numpyModule.attr("ndarray")
  )
}

/**
 * Checks if a value has custom indexing behavior.
 * True for classes with custom __getitem__ or numpy arrays.
 */
predicate has_custom_getitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(value.getClass())
}

/**
 * Identifies control flow nodes explicitly passed to hash().
 */
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashCallNode, GlobalVariable hashGlobalVar |
    hashCallNode.getArg(0) = cfNode and 
    hashCallNode.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

/**
 * Determines if a subscript operation uses an unhashable index.
 * Requires the target object to not have custom indexing behavior.
 */
predicate unhashable_subscript(ControlFlowNode indexCfNode, ClassValue unhashableCls, ControlFlowNode originCfNode) {
  is_unhashable(indexCfNode, unhashableCls, originCfNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexCfNode |
    exists(Value targetObjValue |
      subscriptNode.getObject().pointsTo(targetObjValue) and
      not has_custom_getitem(targetObjValue)
    )
  )
}

/**
 * Checks if an object is unhashable.
 * True for new-style classes without __hash__ or with __hash__ = None.
 */
predicate is_unhashable(ControlFlowNode cfNode, ClassValue targetCls, ControlFlowNode originCfNode) {
  exists(Value value | cfNode.pointsTo(value, originCfNode) and value.getClass() = targetCls |
    (not targetCls.hasAttribute("__hash__") and 
     not targetCls.failedInference(_) and 
     targetCls.isNewStyle())
    or
    targetCls.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Checks if a control flow node is within a try block catching TypeError.
 * Used to eliminate false positives where TypeError is explicitly handled.
 */
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query finding unhandled unhashable operations
from ControlFlowNode problemCfNode, ClassValue problemCls, ControlFlowNode originCfNode
where
  not typeerror_is_caught(problemCfNode) and
  (
    explicitly_hashed(problemCfNode) and 
    is_unhashable(problemCfNode, problemCls, originCfNode)
    or
    unhashable_subscript(problemCfNode, problemCls, originCfNode)
  )
select problemCfNode.getNode(), "This $@ of $@ is unhashable.", originCfNode, "instance", problemCls, problemCls.getQualifiedName()