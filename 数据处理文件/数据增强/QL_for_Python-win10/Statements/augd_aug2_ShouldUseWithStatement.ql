/**
 * @name Should use a 'with' statement
 * @description Identifies try-finally blocks solely used for resource cleanup,
 *              which can be replaced with 'with' statements for improved readability
 *              and automatic resource management.
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
predicate isCloseMethodCall(Call closeInvocation) { 
    exists(Attribute attr | 
        closeInvocation.getFunc() = attr and 
        attr.getName() = "close"
    ) 
}

// Checks if a try statement's finally block contains only a single close call
predicate hasOnlyCloseInFinally(Try tryStatement, Call closeInvocation) {
    exists(ExprStmt statement |
        tryStatement.getAFinalstmt() = statement and 
        statement.getValue() = closeInvocation and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode node, ClassValue contextMgrClass) {
    forex(Value value | node.pointsTo(value) | 
        value.getClass() = contextMgrClass
    ) and
    contextMgrClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStmt, ClassValue contextMgr
where
    hasOnlyCloseInFinally(tryStmt, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode targetNode | 
        targetNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(targetNode, contextMgr)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextMgr, contextMgr.getName()