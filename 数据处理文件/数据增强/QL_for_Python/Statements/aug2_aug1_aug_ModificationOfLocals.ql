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

// Identifies control flow nodes that reference the result of a locals() function call
predicate referencesLocalsCall(ControlFlowNode controlFlowNode) { 
    controlFlowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects dictionary subscript operations (assignment or deletion) on the locals() dictionary
predicate modifiesLocalsViaSubscript(ControlFlowNode subscriptNode) {
    exists(SubscriptNode subscript |
        subscript = subscriptNode and
        referencesLocalsCall(subscript.getObject()) and
        (subscript.isStore() or subscript.isDelete())
    )
}

// Detects dictionary method calls that modify content on the locals() dictionary
predicate modifiesLocalsViaMethod(ControlFlowNode methodCall) {
    exists(CallNode call, AttrNode attributeNode, string methodName |
        call = methodCall and
        attributeNode = call.getFunction() and
        referencesLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Detects any modification operation on the dictionary returned by locals()
predicate modifiesLocalsDictionary(ControlFlowNode dictModificationNode) {
    modifiesLocalsViaSubscript(dictModificationNode) or
    modifiesLocalsViaMethod(dictModificationNode)
}

from AstNode codeNode, ControlFlowNode dictModificationNode
where
    // Find operations modifying the locals() dictionary
    modifiesLocalsDictionary(dictModificationNode) and
    // Map control flow node to corresponding AST node
    codeNode = dictModificationNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not codeNode.getScope() instanceof ModuleScope
// Output results with warning message
select codeNode, "Modification of the locals() dictionary will have no effect on the local variables."