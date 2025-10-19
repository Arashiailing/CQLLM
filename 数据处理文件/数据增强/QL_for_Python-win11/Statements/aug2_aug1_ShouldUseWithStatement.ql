/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that exclusively close a resource,
 *              which could be simplified using Python's 'with' statement for improved
 *              readability and maintainability.
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

// Determines if a method call is a 'close' operation
predicate is_close_method_call(Call closeMethodCall) { 
    exists(Attribute closeAttr | 
        closeMethodCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Checks if a finally block contains only a single 'close' method call
predicate is_sole_close_in_finally(Try tryBlock, Call closeCall) {
    exists(ExprStmt closeStatement |
        tryBlock.getAFinalstmt() = closeStatement and 
        closeStatement.getValue() = closeCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate refers_to_context_manager(ControlFlowNode objectFlowNode, ClassValue managerClass) {
    forex(Value pointedObject | 
        objectFlowNode.pointsTo(pointedObject) | 
        pointedObject.getClass() = managerClass
    ) and
    managerClass.isContextManager()
}

// Finds instances where context managers are closed in finally blocks
from Call closeCall, Try tryBlock, ClassValue managerClass
where
    is_sole_close_in_finally(tryBlock, closeCall) and
    is_close_method_call(closeCall) and
    exists(ControlFlowNode objectFlowNode | 
        objectFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refers_to_context_manager(objectFlowNode, managerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerClass, managerClass.getName()