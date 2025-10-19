/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that exclusively close resources,
 *              which can be simplified using 'with' statements for improved
 *              code clarity and maintainability.
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

// Determines if a call invokes the 'close' method
predicate isCloseMethodCall(Call closeCall) { 
    exists(Attribute attr | 
        closeCall.getFunc() = attr and 
        attr.getName() = "close"
    ) 
}

// Checks if a try statement's finally block contains only a single close call
predicate hasOnlyCloseInFinally(Try tryStmt, Call closeCall) {
    exists(ExprStmt stmt |
        tryStmt.getAFinalstmt() = stmt and 
        stmt.getValue() = closeCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode flowNode, ClassValue contextManagerClass) {
    forex(Value value | flowNode.pointsTo(value) | 
        value.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call close, Try tryStatement, ClassValue contextManager
where
    hasOnlyCloseInFinally(tryStatement, close) and
    isCloseMethodCall(close) and
    exists(ControlFlowNode targetNode | 
        targetNode = close.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(targetNode, contextManager)
    )
select close,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManager, contextManager.getName()