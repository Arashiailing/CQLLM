/**
 * @name Modification of dictionary returned by locals()
 * @description Detects code that modifies the dictionary from locals(), which has no effect on local variables.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Identifies control flow nodes referencing locals() call results
predicate referencesLocalsCall(ControlFlowNode cfNode) { 
    cfNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects dictionary subscript operations (assignment/deletion) on locals() results
predicate isDictionaryModification(ControlFlowNode modNode) {
    exists(SubscriptNode subNode |
        subNode = modNode and
        referencesLocalsCall(subNode.getObject()) and
        (subNode.isStore() or subNode.isDelete())
    )
}

// Detects mutating method calls (pop/update/etc.) on locals() results
predicate isMethodCallModification(ControlFlowNode modNode) {
    exists(CallNode callNode, AttrNode attrNode, string method |
        callNode = modNode and
        attrNode = callNode.getFunction() and
        referencesLocalsCall(attrNode.getObject(method)) and
        method in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode syntaxNode, ControlFlowNode modNode
where
    // Combines detection of both modification types
    (isDictionaryModification(modNode) or isMethodCallModification(modNode)) and
    // Maps control flow node to AST node
    syntaxNode = modNode.getNode() and
    // Excludes module-level operations (locals() ≡ globals() there)
    not syntaxNode.getScope() instanceof ModuleScope
// Selects problematic nodes with warning message
select syntaxNode, "Modification of the locals() dictionary will have no effect on the local variables."