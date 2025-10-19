/**
 * @name Raising a tuple in Python 2
 * @description Detects instances where a tuple is raised as an exception in Python 2.
 *              In Python 2, raising a tuple causes only the first element to be raised
 *              as an exception, while all other elements are silently discarded.
 *              This behavior can lead to unexpected runtime issues and bugs.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// This query identifies raise statements that use a tuple as the exception object.
// In Python 2, this behavior is allowed but problematic because only the first
// element of the tuple will be raised, potentially causing confusion and bugs.
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // This issue is specific to Python 2 environments
  major_version() = 2 and
  // The source of data flow must be a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // There must be a data flow path from the tuple to the exception being raised
  exists(DataFlow::Node targetNode |
    // Connect the target node to the exception in the raise statement
    targetNode.asExpr() = raiseStmt.getException() and
    // Verify that data flows from the tuple source to the target
    tupleSource.flowsTo(targetNode)
  )
/* Note: In Python 3, attempting to raise a tuple results in a TypeError,
   which is handled by the IllegalRaise query. This makes the current query
   specifically relevant for Python 2 codebases where this behavior is allowed
   but potentially problematic. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"