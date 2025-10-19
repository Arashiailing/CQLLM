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
predicate numpy_array_type(ClassValue arrCls) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrCls.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value has custom __getitem__ implementation or is a numpy array
predicate has_custom_getitem(Value val) {
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(val.getClass())
}

// Checks if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableCls, ControlFlowNode origin) {
  exists(Value val | 
    node.pointsTo(val, origin) and 
    val.getClass() = unhashableCls |
    (
      not unhashableCls.hasAttribute("__hash__") and 
      not unhashableCls.failedInference(_) and 
      unhashableCls.isNewStyle()
    )
    or
    unhashableCls.lookup("__hash__") = Value::named("None")
  )
}

// Identifies nodes that are explicitly hashed using the hash() function
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode origin) {
  is_unhashable(indexNode, unhashableCls, origin) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
    exists(Value targetVal |
      subscriptOp.getObject().pointsTo(targetVal) and
      not has_custom_getitem(targetVal)
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
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query finding unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode problemNode, ClassValue problemCls, ControlFlowNode origin
where
  not typeerror_is_caught(problemNode) and
  (
    explicitly_hashed(problemNode) and is_unhashable(problemNode, problemCls, origin)
    or
    unhashable_subscript(problemNode, problemCls, origin)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", origin, "instance", problemCls, problemCls.getQualifiedName()