/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks containing only a single resource close operation
 *              that can be simplified using 'with' statements for improved readability.
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

// Identifies try-finally blocks with context manager resources that could use 'with' statements
from Call resourceCloseCall, Try tryFinallyStatement, ClassValue contextManagerClass
where
  // Verify finally block contains exactly one statement which is a resource close call
  exists(ExprStmt finalStatement |
    tryFinallyStatement.getAFinalstmt() = finalStatement and 
    finalStatement.getValue() = resourceCloseCall and 
    strictcount(tryFinallyStatement.getAFinalstmt()) = 1
  ) and
  // Confirm the call invokes a 'close' method
  exists(Attribute closeMethod |
    resourceCloseCall.getFunc() = closeMethod and 
    closeMethod.getName() = "close"
  ) and
  // Ensure the closed object is a context manager instance
  exists(ControlFlowNode resourceFlowNode | 
    resourceFlowNode = resourceCloseCall.getFunc().getAFlowNode().(AttrNode).getObject() and
    exists(Value resourceValue | 
      resourceFlowNode.pointsTo(resourceValue) and 
      resourceValue.getClass() = contextManagerClass and
      contextManagerClass.isContextManager()
    )
  )
select resourceCloseCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()