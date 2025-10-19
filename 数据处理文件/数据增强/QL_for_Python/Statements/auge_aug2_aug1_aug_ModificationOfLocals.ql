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
predicate referencesLocalsCall(ControlFlowNode cfNode) { 
    cfNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects dictionary subscript operations (assignment or deletion) on the locals() dictionary
predicate modifiesLocalsViaSubscript(ControlFlowNode subscriptOp) {
    exists(SubscriptNode sub |
        sub = subscriptOp and
        referencesLocalsCall(sub.getObject()) and
        (sub.isStore() or sub.isDelete())
    )
}

// Detects dictionary method calls that modify content on the locals() dictionary
predicate modifiesLocalsViaMethod(ControlFlowNode methodOp) {
    exists(CallNode callNode, AttrNode attrNode, string methodName |
        callNode = methodOp and
        attrNode = callNode.getFunction() and
        referencesLocalsCall(attrNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Detects any modification operation on the dictionary returned by locals()
predicate modifiesLocalsDictionary(ControlFlowNode dictModNode) {
    modifiesLocalsViaSubscript(dictModNode) or
    modifiesLocalsViaMethod(dictModNode)
}

from AstNode astNode, ControlFlowNode dictModNode
where
    // Identify operations modifying the locals() dictionary
    modifiesLocalsDictionary(dictModNode) and
    // Map control flow node to corresponding AST node
    astNode = dictModNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Output results with warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."