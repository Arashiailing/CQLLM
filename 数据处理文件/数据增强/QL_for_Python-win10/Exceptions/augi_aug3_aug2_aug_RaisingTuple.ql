/**
 * @name Raising a tuple in Python 2
 * @description Identifies Python 2 code where tuples are raised as exceptions.
 *              This causes only the first element to be raised while others are discarded,
 *              leading to potential runtime issues.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Detects raise statements where the exception originates from a tuple expression
// In Python 2, only the first tuple element is raised, others are silently discarded
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // Target Python 2 environments only
  major_version() = 2 and
  // Source must be a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* Note: Python 3 handles this differently by raising a TypeError (covered by IllegalRaise query).
   This query specifically targets Python 2 codebases. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"