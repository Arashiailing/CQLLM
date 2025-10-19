/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that exclusively close resources,
 *              which could be simplified using 'with' statements for improved
 *              code readability and maintainability.
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

// Determines if a call expression invokes the 'close' method
predicate isCloseMethodCall(Call closeCallExpr) { 
    exists(Attribute attr | 
        closeCallExpr.getFunc() = attr and 
        attr.getName() = "close"
    ) 
}

// Checks if a try statement's finally block contains only a single close call
predicate hasOnlyCloseInFinally(Try tryStatement, Call closeCallExpr) {
    exists(ExprStmt statement |
        tryStatement.getAFinalstmt() = statement and 
        statement.getValue() = closeCallExpr and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode node, ClassValue contextMgrClass) {
    forex(Value pointedValue | node.pointsTo(pointedValue) | 
        pointedValue.getClass() = contextMgrClass
    ) and
    contextMgrClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStatement, ClassValue contextMgr
where
    // Ensure the finally block contains only a close call
    hasOnlyCloseInFinally(tryStatement, closeCall) and
    // Verify the call is to a 'close' method
    isCloseMethodCall(closeCall) and
    // Check the closed object is a context manager
    exists(ControlFlowNode targetObjectNode | 
        // Get the object being closed
        targetObjectNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        // Verify it's a context manager instance
        referencesContextManager(targetObjectNode, contextMgr)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextMgr, contextMgr.getName()