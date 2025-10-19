/**
 * @name Modification of dictionary returned by locals()
 * @description This query detects code that attempts to modify the dictionary returned by locals(). Such modifications do not affect the actual local variables, leading to potential misunderstandings.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Identifies control flow nodes that refer to the return value of a locals() function call
predicate referencesLocalsResult(ControlFlowNode cfgNode) { 
    cfgNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects operations modifying the locals() dictionary through subscript access or method calls
predicate modifiesLocalsDictionary(ControlFlowNode modificationNode) {
    // Case 1: Dictionary subscript operations (assignment or deletion)
    exists(SubscriptNode subscriptAccess |
        subscriptAccess = modificationNode and
        referencesLocalsResult(subscriptAccess.getObject()) and
        (subscriptAccess.isStore() or subscriptAccess.isDelete())
    )
    or
    // Case 2: Dictionary method calls that mutate content
    exists(CallNode methodCall, AttrNode attributeRef, string mutatingMethod |
        methodCall = modificationNode and
        attributeRef = methodCall.getFunction() and
        referencesLocalsResult(attributeRef.getObject(mutatingMethod)) and
        mutatingMethod in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode astNode, ControlFlowNode dictAlterationNode
where
    // Identify operations modifying the locals() dictionary
    modifiesLocalsDictionary(dictAlterationNode) and
    // Map control flow node to corresponding AST node
    astNode = dictAlterationNode.getNode() and
    // Exclude module-level scope where locals() behaves like globals()
    not astNode.getScope() instanceof ModuleScope
// Output results with warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."