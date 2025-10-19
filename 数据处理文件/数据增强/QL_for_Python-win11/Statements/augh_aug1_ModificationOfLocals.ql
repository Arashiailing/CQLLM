/**
 * @name Modification of dictionary returned by locals()
 * @description Detects modifications to the dictionary returned by locals(),
 *              which do not affect the actual local variables in a function.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

/**
 * Identifies control flow nodes that originate from a locals() function call.
 * This serves as the foundation for detecting modifications to the locals() dictionary.
 */
predicate isLocalsCallSource(ControlFlowNode sourceNode) { 
    sourceNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

/**
 * Detects subscript-based modifications (e.g., dict[key] = value or del dict[key])
 * to the dictionary returned by locals().
 */
predicate isSubscriptModification(ControlFlowNode subscriptOp) {
    // Verify the object being subscripted originates from locals()
    isLocalsCallSource(subscriptOp.(SubscriptNode).getObject()) and
    // Confirm this is either a store or delete operation
    (subscriptOp.isStore() or subscriptOp.isDelete())
}

/**
 * Detects method-based modifications (e.g., dict.update(), dict.pop())
 * to the dictionary returned by locals().
 */
predicate isMethodModification(ControlFlowNode methodCall) {
    exists(string methodName, AttrNode attrAccess |
        // Extract the attribute node representing the method being called
        attrAccess = methodCall.(CallNode).getFunction() and
        // Verify the object on which the method is called comes from locals()
        isLocalsCallSource(attrAccess.getObject(methodName))
    |
        // Check if the method is one that modifies the dictionary
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

/**
 * Combines detection of all types of modifications to the locals() dictionary,
 * including both subscript operations and method calls.
 */
predicate hasLocalsModification(ControlFlowNode modOperation) {
    isSubscriptModification(modOperation) or
    isMethodModification(modOperation)
}

// Main query: Identify and report modifications to the locals() dictionary
from AstNode astNode, ControlFlowNode modOperation
where
    // Confirm there is a modification to the locals() dictionary
    hasLocalsModification(modOperation) and
    // Map the control flow node to its corresponding AST node
    astNode = modOperation.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Report the finding with an appropriate warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."