/**
 * @name Modification of dictionary returned by locals()
 * @description Detects code that attempts to modify the dictionary returned by locals(),
 *              which has no actual effect on the local variables in the scope.
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
// This predicate serves as a foundation for detecting modifications to the locals dictionary
predicate referencesLocalsResult(ControlFlowNode cfNode) { 
    cfNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// Detects dictionary subscript operations (assignment or deletion) performed on the locals() dictionary
// These operations appear to modify local variables but actually only affect the returned dictionary copy
predicate modifiesLocalsViaSubscript(ControlFlowNode subscriptModifyOp) {
    exists(SubscriptNode subscript |
        subscript = subscriptModifyOp and
        referencesLocalsResult(subscript.getObject()) and
        (subscript.isStore() or subscript.isDelete())
    )
}

// Detects dictionary method calls that modify content on the locals() dictionary
// These methods include pop, popitem, update, and clear which modify dictionary contents
predicate modifiesLocalsViaMethod(ControlFlowNode methodModifyCall) {
    exists(CallNode call, AttrNode attributeNode, string methodName |
        call = methodModifyCall and
        attributeNode = call.getFunction() and
        referencesLocalsResult(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// Combines all detection patterns to identify any modification operation on the locals() dictionary
// This unified predicate captures both subscript-based and method-based modification attempts
predicate attemptsLocalsModification(ControlFlowNode localsDictModifyNode) {
    modifiesLocalsViaSubscript(localsDictModifyNode) or
    modifiesLocalsViaMethod(localsDictModifyNode)
}

from AstNode codeNode, ControlFlowNode localsDictModifyNode
where
    // Identify operations that attempt to modify the locals() dictionary
    attemptsLocalsModification(localsDictModifyNode) and
    // Map control flow node to its corresponding AST node for result reporting
    codeNode = localsDictModifyNode.getNode() and
    // Exclude module-level scope where locals() is equivalent to globals()
    // and modifications would actually affect global variables
    not codeNode.getScope() instanceof ModuleScope
// Output the identified code nodes with an appropriate warning message
select codeNode, "Modification of the locals() dictionary will have no effect on the local variables."