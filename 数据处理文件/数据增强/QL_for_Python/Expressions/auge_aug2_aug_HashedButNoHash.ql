/**
 * @name Unhashable object hashed
 * @description Detects unhashable objects used in hashing contexts which cause runtime TypeErrors.
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
 * Numpy arrays may use list indices (which are unhashable) and require special consideration.
 */

// Core predicate to identify unhashable objects
predicate is_unhashable_object(ControlFlowNode targetNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  exists(Value value | targetNode.pointsTo(value, originNode) and value.getClass() = unhashableClass |
    (not unhashableClass.hasAttribute("__hash__") and 
     not unhashableClass.failedInference(_) and 
     unhashableClass.isNewStyle())
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Identifies numpy array types by checking inheritance from numpy.ndarray
predicate is_numpy_array_type(ClassValue numpyArrayClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value has a custom __getitem__ implementation
predicate has_custom_getitem_method(Value container) {
  container.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(container.getClass())
}

// Detects explicit hash() function calls
predicate is_explicitly_hashed(ControlFlowNode nodeToCheck) {
  exists(CallNode hashCall, GlobalVariable hashGlobalVar |
    hashCall.getArg(0) = nodeToCheck and 
    hashCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Checks if a subscript operation uses an unhashable index
predicate uses_unhashable_index(ControlFlowNode indexExpr, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable_object(indexExpr, unhashableClass, originNode) and
  exists(SubscriptNode subscriptExpr | subscriptExpr.getIndex() = indexExpr |
    exists(Value container |
      subscriptExpr.getObject().pointsTo(container) and
      not has_custom_getitem_method(container)
    )
  )
}

/**
 * Identifies nodes protected by TypeError-catching try blocks.
 * This reduces false positives by excluding cases where:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 * Since unhashable operations throw TypeError, explicit handling indicates intentional behavior.
 */
predicate is_inside_typeerror_handler(ControlFlowNode targetNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(targetNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable operations
from ControlFlowNode errorNode, ClassValue errorClass, ControlFlowNode originNode
where
  not is_inside_typeerror_handler(errorNode) and
  (
    (is_explicitly_hashed(errorNode) and is_unhashable_object(errorNode, errorClass, originNode))
    or
    uses_unhashable_index(errorNode, errorClass, originNode)
  )
select errorNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", errorClass, errorClass.getQualifiedName()