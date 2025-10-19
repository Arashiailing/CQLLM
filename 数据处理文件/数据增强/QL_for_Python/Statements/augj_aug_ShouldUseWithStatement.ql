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
predicate isCloseMethodCall(Call methodCall) { 
    exists(Attribute attr | methodCall.getFunc() = attr and attr.getName() = "close") 
}

// Checks if a finally block contains only a single close call
predicate isFinallyBlockWithOnlyCloseCall(Try tryStatement, Call closeCall) {
    exists(ExprStmt stmt |
        tryStatement.getAFinalstmt() = stmt and 
        stmt.getValue() = closeCall and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManagerInstance(ControlFlowNode flowNode, ClassValue contextManagerClass) {
    forex(Value v | flowNode.pointsTo(v) | v.getClass() = contextManagerClass) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStatement, ControlFlowNode objectFlowNode, ClassValue contextManagerClass
where
    isFinallyBlockWithOnlyCloseCall(tryStatement, closeCall) and
    isCloseMethodCall(closeCall) and
    objectFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
    referencesContextManagerInstance(objectFlowNode, contextManagerClass)
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()