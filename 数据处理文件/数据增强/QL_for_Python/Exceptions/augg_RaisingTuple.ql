/**
 * @name Raising a tuple
 * @description In Python 2, raising a tuple causes only the first element to be raised
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements and their source nodes
from Raise raiseStmt, DataFlow::LocalSourceNode sourceNode
where
  // Verify Python 2 environment (tuple raising is invalid in Python 3)
  major_version() = 2 and
  // Confirm the source node represents a tuple expression
  sourceNode.asExpr() instanceof Tuple and
  // Trace data flow from source to exception in raise statement
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    sourceNode.flowsTo(exceptionNode)
  )
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  sourceNode, "tuple"