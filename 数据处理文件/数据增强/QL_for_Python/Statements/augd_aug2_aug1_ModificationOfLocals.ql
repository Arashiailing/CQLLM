/**
 * @name Modification of dictionary returned by locals()
 * @description Identifies code that attempts to modify the dictionary returned by locals(),
 *              which is ineffective for changing actual local variables in Python functions.
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
predicate isLocalsReference(ControlFlowNode controlFlowNode) { 
    controlFlowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Identifies modifications to locals() dictionary through subscript/index operations
predicate isIndexingUpdate(ControlFlowNode indexingNode) {
    // Verify that the object being indexed comes from a locals() call
    isLocalsReference(indexingNode.(SubscriptNode).getObject()) and
    // Confirm this is either an assignment or deletion operation
    (indexingNode.isStore() or indexingNode.isDelete())
}

// Identifies modifications to locals() dictionary through method invocations
predicate isFunctionCallUpdate(ControlFlowNode functionCallNode) {
    exists(string functionName, AttrNode attributeNode |
        // Retrieve the attribute node representing the method being called
        attributeNode = functionCallNode.(CallNode).getFunction() and
        // Verify the attribute belongs to a locals() call result
        isLocalsReference(attributeNode.getObject(functionName))
    |
        // Check if the method name is among dictionary-modifying functions
        functionName in ["pop", "popitem", "update", "clear"]
    )
}

// Combines detection of all types of modifications to locals() dictionary
predicate hasLocalsModification(ControlFlowNode modificationNode) {
    isIndexingUpdate(modificationNode) or
    isFunctionCallUpdate(modificationNode)
}

// Main query: Locate and report operations that modify the locals() dictionary
from AstNode astNode, ControlFlowNode modificationOperationNode
where
    // Ensure there's a modification to the locals() dictionary
    hasLocalsModification(modificationOperationNode) and
    // Map the control flow node to its corresponding AST node
    astNode = modificationOperationNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Select results with warning message about ineffective modification
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."