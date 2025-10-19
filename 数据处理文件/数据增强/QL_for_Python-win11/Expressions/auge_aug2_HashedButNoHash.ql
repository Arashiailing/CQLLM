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
 * It assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * Sequences require integer indices (which are hashable), so they don't need special handling.
 * Numpy arrays may use lists as indices (which are unhashable), requiring special attention.
 */

// Determines if a class represents a numpy array type (inherits from numpy.ndarray or numpy.core.ndarray)
predicate numpy_array_type(ClassValue arrayClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value has a custom __getitem__ method (including numpy arrays)
predicate has_custom_getitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetValue.getClass())
}

// Identifies control flow nodes passed as arguments to the built-in hash() function (explicit hashing)
predicate explicitly_hashed(ControlFlowNode targetNode) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = targetNode and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Detects unhashable objects used as indices in subscript operations where the container lacks custom __getitem__
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptOp.getObject().pointsTo(containerValue) and
      not has_custom_getitem(containerValue)
    )
  )
}

// Determines if a control flow node points to a value of an unhashable class (no __hash__ or __hash__=None)
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode) {
  exists(Value targetValue | 
    node.pointsTo(targetValue, originNode) and 
    targetValue.getClass() = unhashableClass and
    (
      (not unhashableClass.hasAttribute("__hash__") and 
       not unhashableClass.failedInference(_) and 
       unhashableClass.isNewStyle())
      or
      unhashableClass.lookup("__hash__") = Value::named("None")
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
 * This predicate eliminates false positives where unhashable operations are intentionally handled.
 */
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable objects in hashing or subscript contexts
from ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode
where
  not typeerror_is_caught(node) and
  (
    explicitly_hashed(node) and is_unhashable(node, unhashableClass, originNode)
    or
    unhashable_subscript(node, unhashableClass, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableClass, unhashableClass.getQualifiedName()