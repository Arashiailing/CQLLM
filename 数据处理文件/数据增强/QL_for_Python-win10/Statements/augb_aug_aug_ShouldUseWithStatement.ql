/**
 * @name Should use a 'with' statement
 * @description Identifies try-finally blocks that exclusively close a resource, 
 *              which reduces code readability. Using 'with' statements is the 
 *              preferred approach for resource management in Python.
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

// Determines if a call invokes a 'close' method
predicate invokesCloseMethod(Call closeMethodCall) { 
    exists(Attribute closeAttr | 
        closeMethodCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Checks if a try block's finally clause contains exactly one statement: a close call
predicate finallyContainsOnlyCloseCall(Try tryStmt, Call closeMethodCall) {
    exists(ExprStmt finalStmt |
        tryStmt.getAFinalstmt() = finalStmt and 
        finalStmt.getValue() = closeMethodCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode objFlowNode, ClassValue contextMgrClass) {
    exists(Value value | 
        objFlowNode.pointsTo(value) and 
        value.getClass() = contextMgrClass
    ) and
    contextMgrClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeMethodCall, Try tryStmt, ClassValue contextMgrClass
where
    finallyContainsOnlyCloseCall(tryStmt, closeMethodCall) and
    invokesCloseMethod(closeMethodCall) and
    exists(ControlFlowNode objFlowNode | 
        objFlowNode = closeMethodCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(objFlowNode, contextMgrClass)
    )
select closeMethodCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextMgrClass, contextMgrClass.getName()