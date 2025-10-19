/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks that only close resources, which can be simplified
 *              using 'with' statements for better readability and maintainability.
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
    exists(Attribute attr | 
        methodCall.getFunc() = attr and 
        attr.getName() = "close"
    ) 
}

// Checks if a try statement's finally block contains only a single close call
predicate hasOnlyCloseInFinally(Try tryStatement, Call methodCall) {
    exists(ExprStmt statement |
        tryStatement.getAFinalstmt() = statement and 
        statement.getValue() = methodCall and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode node, ClassValue managerType) {
    forex(Value value | node.pointsTo(value) | 
        value.getClass() = managerType
    ) and
    managerType.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStatement, ClassValue managerType
where
    hasOnlyCloseInFinally(tryStatement, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode targetNode | 
        targetNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(targetNode, managerType)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerType, managerType.getName()