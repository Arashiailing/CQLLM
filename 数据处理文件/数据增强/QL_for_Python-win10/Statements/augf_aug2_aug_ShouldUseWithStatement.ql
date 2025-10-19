/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks containing only a single resource close operation,
 *              which can be simplified using 'with' statements for better readability.
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

// Checks if a call invokes a method named 'close'
predicate isMethodNamedClose(Call callNode) { 
    exists(Attribute attr | 
        callNode.getFunc() = attr and 
        attr.getName() = "close"
    ) 
}

// Determines if a try statement's finally block contains exactly one close call
predicate isTryFinallyWithSingleCloseCall(Try tryStmt, Call closeCall) {
    exists(ExprStmt stmt |
        tryStmt.getAFinalstmt() = stmt and 
        stmt.getValue() = closeCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate isNodeReferencingContextManager(ControlFlowNode flowNode, ClassValue cls) {
    forex(Value pointedValue | flowNode.pointsTo(pointedValue) | 
        pointedValue.getClass() = cls
    ) and
    cls.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStmt, ClassValue cls
where
    isTryFinallyWithSingleCloseCall(tryStmt, closeCall) and
    isMethodNamedClose(closeCall) and
    exists(ControlFlowNode objectNode | 
        objectNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        isNodeReferencingContextManager(objectNode, cls)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    cls, cls.getName()