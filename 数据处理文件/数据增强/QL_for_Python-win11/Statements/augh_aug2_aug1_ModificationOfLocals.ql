/**
 * @name Modification of dictionary returned by locals()
 * @description Identifies code that modifies the dictionary returned by locals(),
 *              which has no effect on the actual local variables in a function.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Determines if a control flow node references the locals() function call
predicate isLocalsReference(ControlFlowNode controlNode) { 
    controlNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects modifications to the locals() dictionary through subscript operations
predicate isSubscriptUpdate(ControlFlowNode indexNode) {
    // Verify that the subscript operation is performed on the result of locals()
    isLocalsReference(indexNode.(SubscriptNode).getObject()) and
    // Confirm it's a store or delete operation
    (indexNode.isStore() or indexNode.isDelete())
}

// Detects modifications to the locals() dictionary through method calls
predicate isMethodUpdate(ControlFlowNode funcCallNode) {
    exists(string funcName, AttrNode attributeNode |
        // Get the attribute node for the method call
        attributeNode = funcCallNode.(CallNode).getFunction() and
        // Verify the attribute object comes from a locals() call
        isLocalsReference(attributeNode.getObject(funcName))
    |
        // Check if the method name is in the set of dictionary-modifying methods
        funcName in ["pop", "popitem", "update", "clear"]
    )
}

// Identifies any modification operation on the dictionary returned by locals()
predicate containsLocalsModification(ControlFlowNode updateNode) {
    isSubscriptUpdate(updateNode) or
    isMethodUpdate(updateNode)
}

// Main query: Locates and reports modifications to the locals() dictionary
from AstNode astNode, ControlFlowNode controlFlowNode
where
    // Confirm there's a modification to the locals() dictionary
    containsLocalsModification(controlFlowNode) and
    // Get the AST node corresponding to the control flow node
    astNode = controlFlowNode.getNode() and
    // Exclude module-level scope, where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Select results and attach warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."