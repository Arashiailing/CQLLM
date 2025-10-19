/**
 * @name Modification of dictionary returned by locals()
 * @description Detects code that attempts to modify the dictionary returned by the locals() function.
 *              Such modifications have no actual effect on local variables and can lead to confusion.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// Checks whether a control flow node references the result of a locals() function call
predicate isLocalsCallResult(ControlFlowNode flowNode) { 
    flowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Finds operations that modify the dictionary returned by locals()
predicate isLocalsDictModification(ControlFlowNode modifyingOperation) {
    // Scenario 1: Dictionary subscript modification (through assignment or deletion)
    exists(SubscriptNode subscriptExpr |
        subscriptExpr = modifyingOperation and
        isLocalsCallResult(subscriptExpr.getObject()) and
        (subscriptExpr.isStore() or subscriptExpr.isDelete())
    )
    or
    // Scenario 2: Dictionary method invocations that alter the dictionary content
    exists(CallNode methodInvocation, AttrNode attributeNode, string methodName |
        methodInvocation = modifyingOperation and
        attributeNode = methodInvocation.getFunction() and
        isLocalsCallResult(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode sourceAstNode, ControlFlowNode modifyingOperation
where
    // Identify operations that modify the dictionary returned by locals()
    isLocalsDictModification(modifyingOperation) and
    // Obtain the AST node corresponding to the control flow node
    sourceAstNode = modifyingOperation.getNode() and
    // Filter out module-level scope since locals() behaves like globals() there
    not sourceAstNode.getScope() instanceof ModuleScope
// Report the finding with an appropriate warning message
select sourceAstNode, "Modification of the locals() dictionary will have no effect on the local variables."