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

// Determines if a class represents a numpy array type
predicate is_numpy_array_type(ClassValue arrayClass) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Checks if a value implements custom __getitem__ (including numpy arrays)
predicate has_custom_getitem_method(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(targetValue.getClass())
}

// Identifies arguments passed to built-in hash() function (explicit hashing)
predicate is_explicitly_hashed(ControlFlowNode targetNode) {
  exists(CallNode callNode, GlobalVariable hashVar |
    callNode.getArg(0) = targetNode and 
    callNode.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Checks if a node points to an unhashable class (no __hash__ or __hash__=None)
predicate is_unhashable_value(ControlFlowNode expressionNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  exists(Value value | 
    expressionNode.pointsTo(value, originNode) and 
    value.getClass() = unhashableClass and
    (
      (not unhashableClass.hasAttribute("__hash__") and 
       not unhashableClass.failedInference(_) and 
       unhashableClass.isNewStyle())
      or
      unhashableClass.lookup("__hash__") = Value::named("None")
    )
  )
}

// Detects unhashable indices in subscript operations where container lacks custom __getitem__
predicate is_unhashable_subscript(ControlFlowNode indexExpr, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable_value(indexExpr, unhashableClass, originNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexExpr |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not has_custom_getitem_method(containerValue)
    )
  )
}

/**
 * Holds if `targetNode` is inside a try block catching TypeError. Example:
 *
 *    try:
 *       ... targetNode ...
 *    except TypeError:
 *       ...
 *
 * Excludes intentionally handled unhashable operations.
 */
predicate is_typeerror_caught(ControlFlowNode targetNode) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(targetNode.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable objects in hashing/subscript contexts
from ControlFlowNode problematicNode, ClassValue unhashableClass, ControlFlowNode originNode
where
  not is_typeerror_caught(problematicNode) and
  (
    is_explicitly_hashed(problematicNode) and is_unhashable_value(problematicNode, unhashableClass, originNode)
    or
    is_unhashable_subscript(problematicNode, unhashableClass, originNode)
  )
select problematicNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableClass, unhashableClass.getQualifiedName()