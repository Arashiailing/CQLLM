/**
 * @name Modification of dictionary returned by locals()
 * @description Identifies code that attempts to modify the dictionary returned by locals(),
 *              which does not actually affect the local variables in the current scope.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Determines if a control flow node references the result of a locals() function call
predicate referencesLocalsCall(ControlFlowNode flowNode) { 
    flowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Checks for dictionary operations (subscript assignment or deletion) on the dictionary returned by locals()
predicate isDictionaryModification(ControlFlowNode modificationNode) {
    exists(SubscriptNode subscriptAccess |
        subscriptAccess = modificationNode and
        referencesLocalsCall(subscriptAccess.getObject()) and
        (subscriptAccess.isStore() or subscriptAccess.isDelete())
    )
}

// Checks for method calls on the dictionary returned by locals() that modify the dictionary content
predicate isMethodCallModification(ControlFlowNode modificationNode) {
    exists(CallNode methodCall, AttrNode attributeAccess, string methodName |
        methodCall = modificationNode and
        attributeAccess = methodCall.getFunction() and
        referencesLocalsCall(attributeAccess.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Determines if there is any modification operation on the dictionary returned by locals()
predicate modifiesLocalsDictionary(ControlFlowNode modificationNode) {
    isDictionaryModification(modificationNode) or
    isMethodCallModification(modificationNode)
}

from AstNode syntaxNode, ControlFlowNode modificationNode
where
    // Find operations that modify the dictionary returned by locals()
    modifiesLocalsDictionary(modificationNode) and
    // Get the AST node corresponding to the control flow node
    syntaxNode = modificationNode.getNode() and
    // Exclude module-level scope, as locals() is equivalent to globals() at module level
    not syntaxNode.getScope() instanceof ModuleScope
// Output the result with a warning message
select syntaxNode, "Modification of the locals() dictionary will have no effect on the local variables."