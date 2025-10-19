/**
 * @name Modification of dictionary returned by locals()
 * @description Identifies code that attempts to modify the dictionary returned by locals(),
 *              which does not affect actual local variables in the function scope.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Determine if a control flow node references the result of a locals() function call
predicate isLocalsDictSource(ControlFlowNode cfNode) { 
    cfNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Check for modifications to the locals() dictionary using subscript operations (e.g., dict[key] = value or del dict[key])
predicate isSubscriptUpdate(ControlFlowNode updateNode) {
    // Verify that the subscript operation is being performed on a locals() dictionary
    isLocalsDictSource(updateNode.(SubscriptNode).getObject()) and
    // Confirm this is either a store or delete operation
    (updateNode.isStore() or updateNode.isDelete())
}

// Check for modifications to the locals() dictionary using method calls (e.g., dict.update(), dict.clear())
predicate isMethodUpdate(ControlFlowNode updateNode) {
    exists(string methodIdentifier, AttrNode attributeNode |
        // Get the attribute node representing the method being called
        attributeNode = updateNode.(CallNode).getFunction() and
        // Verify the attribute object is a locals() dictionary
        isLocalsDictSource(attributeNode.getObject(methodIdentifier))
    |
        // Check if the method is one that modifies a dictionary
        methodIdentifier in ["pop", "popitem", "update", "clear"]
    )
}

// Identify any operation that modifies the locals() dictionary
predicate hasLocalsDictUpdate(ControlFlowNode updateNode) {
    isSubscriptUpdate(updateNode) or
    isMethodUpdate(updateNode)
}

// Main query: Find and report modifications to the locals() dictionary
from AstNode targetNode, ControlFlowNode updateNode
where
    // Confirm there is a modification to the locals() dictionary
    hasLocalsDictUpdate(updateNode) and
    // Get the AST node corresponding to the control flow node
    targetNode = updateNode.getNode() and
    // Exclude module-level scope since locals() is equivalent to globals() there
    not targetNode.getScope() instanceof ModuleScope
// Select the result and include a warning message
select targetNode, "Modification of the locals() dictionary will have no effect on the local variables."