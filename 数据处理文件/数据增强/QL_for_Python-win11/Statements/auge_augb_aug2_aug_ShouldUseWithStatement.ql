/**
 * @name Should use a 'with' statement
 * @description Identifies try-finally blocks containing only a single resource close operation
 *              that could be simplified using 'with' statements for improved readability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/should-use-with
 */

import python

// Determines if the given call invokes a method named 'close'
predicate isCloseMethodCall(Call methodInvocation) { 
    exists(Attribute attribute | 
        methodInvocation.getFunc() = attribute and 
        attribute.getName() = "close"
    ) 
}

// Checks if a try statement's finally block contains exactly one close call
predicate isFinallyBlockWithSingleCloseCall(Try tryBlock, Call closeMethodInvocation) {
    exists(ExprStmt statement |
        tryBlock.getAFinalstmt() = statement and 
        statement.getValue() = closeMethodInvocation and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node points to a context manager instance
predicate flowNodeReferencesContextManager(ControlFlowNode node, ClassValue contextManager) {
    exists(Value value | node.pointsTo(value) | 
        value.getClass() = contextManager
    ) and
    contextManager.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeMethodInvocation, Try tryBlock, ClassValue contextManager
where
    isFinallyBlockWithSingleCloseCall(tryBlock, closeMethodInvocation) and
    isCloseMethodCall(closeMethodInvocation) and
    exists(ControlFlowNode objFlowNode | 
        objFlowNode = closeMethodInvocation.getFunc().getAFlowNode().(AttrNode).getObject() and
        flowNodeReferencesContextManager(objFlowNode, contextManager)
    )
select closeMethodInvocation,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManager, contextManager.getName()