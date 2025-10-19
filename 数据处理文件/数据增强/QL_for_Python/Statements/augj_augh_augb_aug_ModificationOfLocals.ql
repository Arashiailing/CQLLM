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
predicate referencesLocalsCall(ControlFlowNode node) { 
    node.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects all types of modifications to locals() dictionary
predicate isLocalsModification(ControlFlowNode modNode) {
    // Case 1: Dictionary subscript operations (assignment/deletion)
    exists(SubscriptNode subscript | 
        subscript = modNode and
        referencesLocalsCall(subscript.getObject()) and
        (subscript.isStore() or subscript.isDelete())
    )
    or
    // Case 2: Mutating method calls (pop/update/etc.)
    exists(CallNode call, AttrNode attr, string method |
        call = modNode and
        attr = call.getFunction() and
        referencesLocalsCall(attr.getObject(method)) and
        method in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode syntaxNode, ControlFlowNode modNode
where
    isLocalsModification(modNode) and
    syntaxNode = modNode.getNode() and
    // Exclude module-level operations (locals() ≡ globals() there)
    not syntaxNode.getScope() instanceof ModuleScope
select syntaxNode, "Modification of the locals() dictionary will have no effect on the local variables."