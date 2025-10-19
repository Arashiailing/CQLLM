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

/**
 * This query identifies unhashable objects used in hashing contexts.
 * It assumes subscript indexing with non-sequence/non-numpy indices involves hashing.
 * Standard sequences require integer indices (hashable) while numpy arrays may use list indices (unhashable).
 */

// Identifies numpy array types through inheritance from numpy.ndarray
predicate numpy_array_type(ClassValue ndarrayClass) {
  exists(ModuleValue npModule | 
    (npModule.getName() = "numpy" or npModule.getName() = "numpy.core") and
    ndarrayClass.getASuperType() = npModule.attr("ndarray")
  )
}

// Determines if a value has custom __getitem__ implementation or is a numpy array
predicate has_custom_getitem(Value containerObj) {
  containerObj.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(containerObj.getClass())
}

// Checks if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableType, ControlFlowNode origin) {
  exists(Value value | 
    node.pointsTo(value, origin) and 
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

// Identifies nodes explicitly hashed using the hash() function
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode callNode, GlobalVariable hashVar |
    callNode.getArg(0) = node and 
    callNode.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate unhashable_subscript(ControlFlowNode idxNode, ClassValue unhashableType, ControlFlowNode origin) {
  is_unhashable(idxNode, unhashableType, origin) and
  exists(SubscriptNode subscript | subscript.getIndex() = idxNode |
    exists(Value containerObj |
      subscript.getObject().pointsTo(containerObj) and
      not has_custom_getitem(containerObj)
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
from ControlFlowNode problemNode, ClassValue problemClass, ControlFlowNode origin
where
  not typeerror_is_caught(problemNode) and
  (
    explicitly_hashed(problemNode) and is_unhashable(problemNode, problemClass, origin)
    or
    unhashable_subscript(problemNode, problemClass, origin)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", origin, "instance", problemClass, problemClass.getQualifiedName()