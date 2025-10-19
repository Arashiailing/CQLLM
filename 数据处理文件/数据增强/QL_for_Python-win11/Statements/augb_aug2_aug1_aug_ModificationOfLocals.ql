/**
 * @name Modification of dictionary returned by locals()
 * @description Identifies code that modifies the dictionary returned by locals(), which does not impact the actual local variables.
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
predicate refersToLocalsCall(ControlFlowNode flowNode) { 
    flowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects dictionary subscript operations (assignment or deletion) on the locals() dictionary
predicate altersLocalsBySubscript(ControlFlowNode subscriptOp) {
    exists(SubscriptNode subscript |
        subscript = subscriptOp and
        refersToLocalsCall(subscript.getObject()) and
        (subscript.isStore() or subscript.isDelete())
    )
}

// Detects dictionary method calls that modify content on the locals() dictionary
predicate altersLocalsByMethod(ControlFlowNode methodInvocation) {
    exists(CallNode call, AttrNode attributeNode, string methodName |
        call = methodInvocation and
        attributeNode = call.getFunction() and
        refersToLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Detects any modification operation on the dictionary returned by locals()
predicate altersLocalsDict(ControlFlowNode dictAlterationNode) {
    altersLocalsBySubscript(dictAlterationNode) or
    altersLocalsByMethod(dictAlterationNode)
}

from AstNode astNode, ControlFlowNode dictAlterationNode
where
    // Find operations modifying the locals() dictionary
    altersLocalsDict(dictAlterationNode) and
    // Map control flow node to corresponding AST node
    astNode = dictAlterationNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    not astNode.getScope() instanceof ModuleScope
// Output results with warning message
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."