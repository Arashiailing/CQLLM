/**
 * @name Raising a tuple
 * @description Raising a tuple will result in all but the first element being discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements in Python 2 code where a tuple is raised
from Raise raiseStmt, DataFlow::LocalSourceNode sourceNode
where
  // Only applicable to Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // The source node must be a tuple expression
  sourceNode.asExpr() instanceof Tuple and
  // There must be a data flow path from the tuple to the raise exception
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    sourceNode.flowsTo(exceptionNode)
  )
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  sourceNode, "tuple"