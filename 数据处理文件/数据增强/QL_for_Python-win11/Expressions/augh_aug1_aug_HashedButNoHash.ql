/**
 * @name Unhashable object hashed
 * @description Attempting to hash an object that lacks hashability causes a TypeError during execution.
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
 * This query detects unhashable values being used in contexts requiring hashability.
 * Hashing contexts encompass:
 * 1. Direct invocations of the hash() built-in function
 * 2. Dictionary/set operations that implicitly require hashable keys
 * 
 * Detection principles:
 * - Sequence types expect integer indices (which are inherently hashable)
 * - NumPy arrays may accept non-hashable indices (such as lists)
 * - Objects are considered unhashable if they either:
 *   a) Lack a __hash__ method implementation, or
 *   b) Explicitly set __hash__ to None
 */

// Determines if a class represents a NumPy array type
predicate represents_numpy_array(ClassValue numpyClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Verifies whether a value implements a custom __getitem__ method
predicate implements_custom_getitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  represents_numpy_array(targetValue.getClass())
}

// Identifies values being explicitly passed to the hash() function
predicate passed_to_hash_function(ControlFlowNode hashedNode) {
  exists(CallNode hashInvocation, GlobalVariable hashReference |
    hashInvocation.getArg(0) = hashedNode and 
    hashInvocation.getFunction().(NameNode).uses(hashReference) and 
    hashReference.getId() = "hash"
  )
}

// Detects subscript operations using unhashable indices
predicate uses_unhashable_index(ControlFlowNode indexExpr, ClassValue unhashableType, ControlFlowNode sourceNode) {
  is_unhashable_object(indexExpr, unhashableType, sourceNode) and
  exists(SubscriptNode subscriptOperation | subscriptOperation.getIndex() = indexExpr |
    exists(Value containerValue |
      subscriptOperation.getObject().pointsTo(containerValue) and
      not implements_custom_getitem(containerValue)
    )
  )
}

// Evaluates whether an object is unhashable
predicate is_unhashable_object(ControlFlowNode exprNode, ClassValue objectType, ControlFlowNode definingNode) {
  exists(Value referencedValue | exprNode.pointsTo(referencedValue, definingNode) and referencedValue.getClass() = objectType |
    (not objectType.hasAttribute("__hash__") and 
     not objectType.failedInference(_) and 
     objectType.isNewStyle())
    or
    objectType.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Holds if `node` is contained within a `try` block that catches `TypeError`.
 * This predicate helps eliminate false positives where the TypeError
 * exception is explicitly caught and handled by the program.
 */
predicate contained_in_typeerror_catch(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Locate unhashable objects in hashing contexts without proper error handling
from ControlFlowNode targetNode, ClassValue unhashableType, ControlFlowNode sourceNode
where
  not contained_in_typeerror_catch(targetNode) and
  (
    (passed_to_hash_function(targetNode) and is_unhashable_object(targetNode, unhashableType, sourceNode))
    or
    uses_unhashable_index(targetNode, unhashableType, sourceNode)
  )
select targetNode.getNode(), "This $@ of $@ cannot be hashed.", sourceNode, "instance", unhashableType, unhashableType.getQualifiedName()