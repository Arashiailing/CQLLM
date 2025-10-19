/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks that only close a resource,
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

// Determines if a call invokes the 'close' method
predicate isCloseCall(Call call) { 
    exists(Attribute attr | call.getFunc() = attr and attr.getName() = "close") 
}

// Checks if a finally block contains only a single close call
predicate isFinallyBlockWithSingleClose(Try tryStmt, Call call) {
    exists(ExprStmt stmt |
        tryStmt.getAFinalstmt() = stmt and 
        stmt.getValue() = call and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode flowNode, ClassValue cls) {
    forex(Value v | flowNode.pointsTo(v) | v.getClass() = cls) and
    cls.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStmt, ClassValue cls
where
    isFinallyBlockWithSingleClose(tryStmt, closeCall) and
    isCloseCall(closeCall) and
    exists(ControlFlowNode objFlowNode | 
        objFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(objFlowNode, cls)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    cls, cls.getName()