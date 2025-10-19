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
predicate numpy_array_type(ClassValue arrType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value has custom __getitem__ implementation or is a numpy array
predicate has_custom_getitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(value.getClass())
}

// Checks if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode cfNode, ClassValue unhashableType, ControlFlowNode origin) {
  exists(Value value | 
    cfNode.pointsTo(value, origin) and 
    value.getClass() = unhashableType |
    (
      not unhashableType.hasAttribute("__hash__") and 
      not unhashableType.failedInference(_) and 
      unhashableType.isNewStyle()
    )
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Identifies nodes that are explicitly hashed using the hash() function
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashInvocation, GlobalVariable hashGlobal |
    hashInvocation.getArg(0) = cfNode and 
    hashInvocation.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate unhashable_subscript(ControlFlowNode idxNode, ClassValue unhashableType, ControlFlowNode origin) {
  is_unhashable(idxNode, unhashableType, origin) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = idxNode |
    exists(Value target |
      subscriptNode.getObject().pointsTo(target) and
      not has_custom_getitem(target)
    )
  )
}

/**
 * Holds if `cfNode` is inside a `try` block that catches `TypeError`. For example:
 *
 *    try:
 *       ... cfNode ...
 *    except TypeError:
 *       ...
 *
 * This predicate eliminates false positives where hashing an unhashable object
 * is intentionally handled by catching the resulting TypeError.
 */
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query finding unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problemCfNode, ClassValue problemType, ControlFlowNode origin
where
  not typeerror_is_caught(problemCfNode) and
  (
    explicitly_hashed(problemCfNode) and is_unhashable(problemCfNode, problemType, origin)
    or
    unhashable_subscript(problemCfNode, problemType, origin)
  )
select problemCfNode.getNode(), "This $@ of $@ is unhashable.", origin, "instance", problemType, problemType.getQualifiedName()