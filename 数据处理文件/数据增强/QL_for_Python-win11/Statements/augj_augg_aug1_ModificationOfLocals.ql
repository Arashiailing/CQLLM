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

// Identifies control flow nodes pointing to locals() function calls
predicate isLocalsCallSource(ControlFlowNode localsCallNode) { 
    localsCallNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Checks for dictionary modifications via subscript operations
predicate isSubscriptModification(ControlFlowNode subscriptNode) {
    // Verify subscript operation targets locals() dictionary
    isLocalsCallSource(subscriptNode.(SubscriptNode).getObject()) and
    // Confirm assignment or deletion operation
    (subscriptNode.isStore() or subscriptNode.isDelete())
}

// Checks for dictionary modifications via method calls
predicate isMethodModification(ControlFlowNode methodCallNode) {
    exists(string methodName, AttrNode methodAttrNode |
        // Get the attribute node for method invocation
        methodAttrNode = methodCallNode.(CallNode).getFunction() and
        // Verify attribute object originates from locals() call
        isLocalsCallSource(methodAttrNode.getObject(methodName))
    |
        // Check against known dictionary modification methods
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Detects any modification operation on locals() dictionary
predicate hasLocalsModification(ControlFlowNode modificationNode) {
    isSubscriptModification(modificationNode) or
    isMethodModification(modificationNode)
}

// Main query: Identify and report locals() dictionary modifications
from AstNode targetNode, ControlFlowNode modificationNode
where
    // Confirm presence of locals() dictionary modification
    hasLocalsModification(modificationNode) and
    // Map control flow node to corresponding AST node
    targetNode = modificationNode.getNode() and
    // Exclude module-level scope where locals() ≡ globals()
    not targetNode.getScope() instanceof ModuleScope
// Select results with warning message
select targetNode, "Modification of the locals() dictionary will have no effect on the local variables."