/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks containing only a single resource close operation,
 *              which can be simplified using 'with' statements for improved readability.
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

// Checks whether the given call invokes a method named 'close'
predicate isCloseMethodCall(Call methodCall) { 
    exists(Attribute attribute | 
        methodCall.getFunc() = attribute and 
        attribute.getName() = "close"
    ) 
}

// Determines if a try statement's finally block contains exactly one close call
predicate isFinallyBlockWithSingleCloseCall(Try tryStatement, Call closeMethodCall) {
    exists(ExprStmt statement |
        tryStatement.getAFinalstmt() = statement and 
        statement.getValue() = closeMethodCall and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate flowNodeReferencesContextManager(ControlFlowNode node, ClassValue contextManagerClass) {
    forex(Value value | node.pointsTo(value) | 
        value.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStmt, ClassValue cls
where
    isFinallyBlockWithSingleCloseCall(tryStmt, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode objectFlowNode | 
        objectFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        flowNodeReferencesContextManager(objectFlowNode, cls)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    cls, cls.getName()