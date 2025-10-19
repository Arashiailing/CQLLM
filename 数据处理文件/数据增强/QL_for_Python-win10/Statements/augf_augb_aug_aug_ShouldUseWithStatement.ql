/**
 * @name Should use a 'with' statement
 * @description Identifies try-finally blocks exclusively used for resource cleanup,
 *              which harms code readability. The 'with' statement provides a cleaner
 *              approach for resource management in Python.
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
predicate isCloseMethodCall(Call resourceCleanupCall) { 
    resourceCleanupCall.getFunc().(Attribute).getName() = "close"
}

// Checks if a try block's finally clause contains exclusively a close call
predicate finallyContainsOnlyCloseCall(Try resourceTryBlock, Call cleanupCall) {
    exists(ExprStmt finalStatement |
        finalStatement = resourceTryBlock.getAFinalstmt() and 
        finalStatement.getValue() = cleanupCall and 
        strictcount(resourceTryBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate isContextManagerReference(ControlFlowNode resourceFlowNode, ClassValue managerClass) {
    exists(Value resourceValue | 
        resourceFlowNode.pointsTo(resourceValue) and 
        resourceValue.getClass() = managerClass and
        managerClass.isContextManager()
    )
}

// Identifies try-finally blocks that exclusively close context managers
from Call cleanupCall, Try resourceTryBlock, ClassValue managerClass
where
    finallyContainsOnlyCloseCall(resourceTryBlock, cleanupCall) and
    isCloseMethodCall(cleanupCall) and
    exists(ControlFlowNode resourceFlowNode | 
        resourceFlowNode = cleanupCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        isContextManagerReference(resourceFlowNode, managerClass)
    )
select cleanupCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerClass, managerClass.getName()