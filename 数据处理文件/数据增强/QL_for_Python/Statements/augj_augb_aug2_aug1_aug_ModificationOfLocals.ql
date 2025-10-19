/**
 * @name Modification of dictionary returned by locals()
 * @description Detects code that modifies the dictionary returned by locals(), which has no effect on actual local variables.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Identifies control flow nodes referencing the result of a locals() call
predicate referencesLocalsCall(ControlFlowNode node) { 
    node.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects dictionary subscript operations (assignment/deletion) on locals() dictionary
predicate modifiesLocalsViaSubscript(ControlFlowNode subscriptNode) {
    exists(SubscriptNode subscript |
        subscript = subscriptNode and
        referencesLocalsCall(subscript.getObject()) and
        (subscript.isStore() or subscript.isDelete())
    )
}

// Detects dictionary method calls that modify content of locals() dictionary
predicate modifiesLocalsViaMethod(ControlFlowNode methodCallNode) {
    exists(CallNode call, AttrNode attributeNode, string methodName |
        call = methodCallNode and
        attributeNode = call.getFunction() and
        referencesLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Detects any modification operation on the dictionary returned by locals()
predicate modifiesLocalsDictionary(ControlFlowNode modificationNode) {
    modifiesLocalsViaSubscript(modificationNode) or
    modifiesLocalsViaMethod(modificationNode)
}

from AstNode astNode, ControlFlowNode modificationNode
where
    // Identify operations modifying the locals() dictionary
    modifiesLocalsDictionary(modificationNode) and
    // Map control flow node to corresponding AST node
    astNode = modificationNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Output results with warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."