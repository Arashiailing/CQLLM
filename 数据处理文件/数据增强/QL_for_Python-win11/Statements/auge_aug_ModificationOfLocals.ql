/**
 * @name Modification of dictionary returned by locals()
 * @description Identifies code that tries to modify the dictionary returned by locals() function,
 *              which has no actual effect on local variables and can be misleading.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Determines if a control flow node refers to the result of a locals() function call
predicate refersToLocalsCallResult(ControlFlowNode controlNode) { 
    controlNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Identifies any operation that modifies the dictionary returned by locals()
predicate modifiesLocalsDict(ControlFlowNode modificationNode) {
    // Case 1: Dictionary subscript modification (assignment or deletion)
    exists(SubscriptNode subscriptOperation |
        subscriptOperation = modificationNode and
        refersToLocalsCallResult(subscriptOperation.getObject()) and
        (subscriptOperation.isStore() or subscriptOperation.isDelete())
    )
    or
    // Case 2: Dictionary method calls that modify the dictionary content
    exists(CallNode methodCallNode, AttrNode attributeAccessNode, string dictMethodName |
        methodCallNode = modificationNode and
        attributeAccessNode = methodCallNode.getFunction() and
        refersToLocalsCallResult(attributeAccessNode.getObject(dictMethodName)) and
        dictMethodName in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode targetAstNode, ControlFlowNode modificationNode
where
    // Find operations that modify the locals() returned dictionary
    modifiesLocalsDict(modificationNode) and
    // Get the AST node corresponding to the control flow node
    targetAstNode = modificationNode.getNode() and
    // Exclude module-level scope since locals() is equivalent to globals() there
    not targetAstNode.getScope() instanceof ModuleScope
// Output the result with a warning message
select targetAstNode, "Modification of the locals() dictionary will have no effect on the local variables."