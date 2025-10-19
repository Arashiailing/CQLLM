/**
 * @name Should use a 'with' statement
 * @description Identifies try-finally blocks that exclusively close context manager resources.
 *              These patterns should be replaced with 'with' statements for improved code clarity
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

// Determines if a function call invokes the 'close' method
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
predicate referencesContextManager(ControlFlowNode flowNode, ClassValue managerType) {
    forex(Value value | flowNode.pointsTo(value) | 
        value.getClass() = managerType
    ) and
    managerType.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStmt, ClassValue managerType, ControlFlowNode objectNode
where
    hasOnlyCloseInFinally(tryStmt, closeCall) and
    isCloseMethodCall(closeCall) and
    objectNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
    referencesContextManager(objectNode, managerType)
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerType, managerType.getName()