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

// Identifies classes representing numpy array types (inheriting from numpy.ndarray or numpy.core.ndarray)
predicate numpy_array_type(ClassValue arrType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value implements a custom __getitem__ method (including numpy arrays)
predicate has_custom_getitem(Value val) {
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(val.getClass())
}

// Detects control flow nodes passed as arguments to the built-in hash() function (explicit hashing)
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashInvocation, GlobalVariable hashGlobal |
    hashInvocation.getArg(0) = cfNode and 
    hashInvocation.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Determines if a control flow node references a value of an unhashable class (no __hash__ or __hash__=None)
predicate is_unhashable(ControlFlowNode cfNode, ClassValue unhashableType, ControlFlowNode sourceNode) {
  exists(Value val | 
    cfNode.pointsTo(val, sourceNode) and 
    val.getClass() = unhashableType and
    (
      unhashableType.lookup("__hash__") = Value::named("None")
      or
      (not unhashableType.hasAttribute("__hash__") and 
       not unhashableType.failedInference(_) and 
       unhashableType.isNewStyle())
    )
  )
}

// Detects unhashable objects used as indices in subscript operations where the container lacks custom __getitem__
predicate unhashable_subscript(ControlFlowNode idxNode, ClassValue unhashableType, ControlFlowNode sourceNode) {
  is_unhashable(idxNode, unhashableType, sourceNode) and
  exists(SubscriptNode subscriptExpr | subscriptExpr.getIndex() = idxNode |
    exists(Value container |
      subscriptExpr.getObject().pointsTo(container) and
      not has_custom_getitem(container)
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
 * This predicate eliminates false positives where unhashable operations are intentionally handled.
 */
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable objects in hashing or subscript contexts
from ControlFlowNode cfNode, ClassValue unhashableType, ControlFlowNode sourceNode
where
  not typeerror_is_caught(cfNode) and
  (
    explicitly_hashed(cfNode) and is_unhashable(cfNode, unhashableType, sourceNode)
    or
    unhashable_subscript(cfNode, unhashableType, sourceNode)
  )
select cfNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", unhashableType, unhashableType.getQualifiedName()