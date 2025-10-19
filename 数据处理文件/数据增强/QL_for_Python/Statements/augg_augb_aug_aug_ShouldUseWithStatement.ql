/**
 * @name Should use a 'with' statement
 * @description Detects try-finally blocks that exclusively close a resource,
 *              which harms code readability. 'with' statements are the preferred
 *              pattern for resource management in Python.
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
predicate invokesCloseMethod(Call closeCall) { 
    exists(Attribute closeAttribute | 
        closeCall.getFunc() = closeAttribute and 
        closeAttribute.getName() = "close"
    ) 
}

// Checks if a try block's finally clause contains exactly one statement: a close call
predicate finallyContainsOnlyCloseCall(Try tryBlock, Call closeCall) {
    exists(ExprStmt finalStatement |
        tryBlock.getAFinalstmt() = finalStatement and 
        finalStatement.getValue() = closeCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode objectNode, ClassValue contextManagerClass) {
    exists(Value value | 
        objectNode.pointsTo(value) and 
        value.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryBlock, ClassValue contextManagerClass
where
    finallyContainsOnlyCloseCall(tryBlock, closeCall) and
    invokesCloseMethod(closeCall) and
    exists(ControlFlowNode objectNode | 
        objectNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(objectNode, contextManagerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()