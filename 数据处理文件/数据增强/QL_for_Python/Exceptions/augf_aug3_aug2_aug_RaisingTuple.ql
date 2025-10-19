/**
 * @name Raising a tuple in Python 2
 * @description Identifies code locations where a tuple is raised as an exception in Python 2.
 *              In Python 2, when a tuple is raised, only the first element is actually raised as an exception,
 *              while all other elements in the tuple are silently discarded. This can lead to unexpected
 *              runtime behavior and potential bugs.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// This query detects raise statements in Python 2 where the exception being raised
// originates from a tuple expression. Such behavior causes only the first element
// of the tuple to be raised, while discarding all other elements.
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // Limit the analysis to Python 2 environments only
  major_version() = 2 and
  // Ensure the source node represents a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Verify that data flows from the tuple to the exception being raised
  exists(DataFlow::Node targetNode |
    targetNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(targetNode)
  )
/* Note: Python 3 handles raising tuples differently by throwing a TypeError,
   which is covered by the IllegalRaise query. This analysis is specifically
   designed for Python 2 codebases where tuple raising is syntactically valid
   but semantically problematic. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"