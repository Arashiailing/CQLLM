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

// Checks if a method call is a 'close' method invocation
predicate isCloseMethodInvocation(Call methodInvocation) { 
    exists(Attribute methodAttr | 
        methodInvocation.getFunc() = methodAttr and 
        methodAttr.getName() = "close"
    ) 
}

// Verifies if a try statement's finally block contains only a close call
predicate hasSingleCloseInFinally(Try tryStatement, Call closeInvocation) {
    exists(ExprStmt finalStatement |
        tryStatement.getAFinalstmt() = finalStatement and 
        finalStatement.getValue() = closeInvocation and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Determines if a flow node references a context manager class instance
predicate referencesContextManager(ControlFlowNode instanceFlowNode, ClassValue managerClass) {
    forex(Value referencedValue | 
        instanceFlowNode.pointsTo(referencedValue) | 
        referencedValue.getClass() = managerClass
    ) and
    managerClass.isContextManager()
}

// Identifies try-finally blocks that exclusively close context managers
from Call closeInvocation, Try tryStatement, ClassValue managerClass
where
    hasSingleCloseInFinally(tryStatement, closeInvocation) and
    isCloseMethodInvocation(closeInvocation) and
    exists(ControlFlowNode instanceFlowNode | 
        instanceFlowNode = closeInvocation.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(instanceFlowNode, managerClass)
    )
select closeInvocation,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerClass, managerClass.getName()