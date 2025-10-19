/**
 * @name Raising a tuple in Python 2
 * @description Identifies cases where a tuple is raised as an exception in Python 2.
 *              This causes only the first element to be raised while discarding others,
 *              potentially leading to unexpected runtime behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// This query detects raise statements in Python 2 where the exception originates from a tuple.
// In such cases, only the first tuple element is raised, and other elements are silently discarded.
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // Target only Python 2 environments
  major_version() = 2 and
  // Ensure the source is a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Verify data flow from tuple to raised exception
  exists(DataFlow::Node exceptionFlowNode |
    exceptionFlowNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionFlowNode)
  )
/* Note: Python 3 handles this differently by raising a TypeError (covered by IllegalRaise query).
   This query specifically targets Python 2 codebases. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"