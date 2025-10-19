/**
 * @name Unhashable object hashed
 * @description Identifies unhashable objects used in hashing contexts that cause runtime TypeErrors.
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
 * This analysis detects unhashable objects used in hashing contexts.
 * It assumes indexing operations with non-sequence/non-numpy-array values involve hashing.
 * Sequences require integer indices (hashable), so they're excluded.
 * Numpy arrays may use list indices (unhashable) and need special handling.
 */

// Core predicate to identify unhashable objects
predicate is_unhashable_object(ControlFlowNode nodeToAnalyze, ClassValue unhashableType, ControlFlowNode sourceNode) {
  exists(Value value | nodeToAnalyze.pointsTo(value, sourceNode) and value.getClass() = unhashableType |
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Identifies numpy array types through inheritance from numpy.ndarray
predicate is_numpy_array_type(ClassValue arrayClass) {
  exists(ModuleValue numpyMod | 
    numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Determines if a value implements custom __getitem__ logic
predicate has_custom_getitem_method(Value containerValue) {
  containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(containerValue.getClass())
}

// Detects explicit hash() function invocations
predicate is_explicitly_hashed(ControlFlowNode examinedNode) {
  exists(CallNode hashFunctionCall, GlobalVariable hashGlobal |
    hashFunctionCall.getArg(0) = examinedNode and 
    hashFunctionCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Checks for subscript operations using unhashable indices
predicate uses_unhashable_index(ControlFlowNode indexExpression, ClassValue unhashableType, ControlFlowNode sourceNode) {
  is_unhashable_object(indexExpression, unhashableType, sourceNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexExpression |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not has_custom_getitem_method(containerValue)
    )
  )
}

/**
 * Identifies nodes protected by TypeError-catching try blocks.
 * Reduces false positives by excluding cases where:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 * Since unhashable operations throw TypeError, explicit handling indicates intentional behavior.
 */
predicate is_inside_typeerror_handler(ControlFlowNode nodeToCheck) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(nodeToCheck.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable operations
from ControlFlowNode problematicNode, ClassValue problematicClass, ControlFlowNode sourceNode
where
  not is_inside_typeerror_handler(problematicNode) and
  (
    (is_explicitly_hashed(problematicNode) and is_unhashable_object(problematicNode, problematicClass, sourceNode))
    or
    uses_unhashable_index(problematicNode, problematicClass, sourceNode)
  )
select problematicNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", problematicClass, problematicClass.getQualifiedName()