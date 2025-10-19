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

// Determines if a control flow node references the result of a locals() call
predicate nodeReferencesLocalsCall(ControlFlowNode flowNode) { 
    flowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Identifies dictionary write/delete operations on locals() result
predicate isDictionaryWriteOrDelete(ControlFlowNode modificationNode) {
    exists(SubscriptNode subscript |
        subscript = modificationNode and
        nodeReferencesLocalsCall(subscript.getObject()) and
        (subscript.isStore() or subscript.isDelete())
    )
}

// Identifies mutating method calls on locals() result
predicate isDictionaryMutatingMethodCall(ControlFlowNode modificationNode) {
    exists(CallNode methodCall, AttrNode attributeAccess, string mutatingMethod |
        methodCall = modificationNode and
        attributeAccess = methodCall.getFunction() and
        nodeReferencesLocalsCall(attributeAccess.getObject(mutatingMethod)) and
        mutatingMethod in ["pop", "popitem", "update", "clear"]
    )
}

// Combines all modification patterns targeting locals() dictionary
predicate modifiesLocalsReturnedDict(ControlFlowNode modificationNode) {
    isDictionaryWriteOrDelete(modificationNode) or
    isDictionaryMutatingMethodCall(modificationNode)
}

from AstNode astNode, ControlFlowNode modificationNode
where
    // Find operations modifying the locals() dictionary
    modifiesLocalsReturnedDict(modificationNode) and
    // Map control flow node to corresponding AST node
    astNode = modificationNode.getNode() and
    // Exclude module-level scope where locals() equals globals()
    not astNode.getScope() instanceof ModuleScope
// Output results with warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."