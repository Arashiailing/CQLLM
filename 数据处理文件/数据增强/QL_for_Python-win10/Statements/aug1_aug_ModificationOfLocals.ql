/**
 * @name Modification of dictionary returned by locals()
 * @description Detects attempts to modify the dictionary returned by locals() which do not affect the actual local variables.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Identifies control flow nodes referencing the result of locals() function call
predicate referencesLocalsCall(ControlFlowNode controlFlowNode) { 
    controlFlowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects any modification operation on the dictionary returned by locals()
predicate modifiesLocalsDictionary(ControlFlowNode modificationNode) {
    // Case 1: Dictionary subscript operations (assignment or deletion)
    exists(SubscriptNode subscriptNode |
        subscriptNode = modificationNode and
        referencesLocalsCall(subscriptNode.getObject()) and
        (subscriptNode.isStore() or subscriptNode.isDelete())
    )
    or
    // Case 2: Dictionary method calls that modify content
    exists(CallNode callNode, AttrNode attributeNode, string methodName |
        callNode = modificationNode and
        attributeNode = callNode.getFunction() and
        referencesLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode astNode, ControlFlowNode modificationNode
where
    // Find operations modifying the locals() dictionary
    modifiesLocalsDictionary(modificationNode) and
    // Map control flow node to corresponding AST node
    astNode = modificationNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Output results with warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."