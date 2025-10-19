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

// Identify raise statements that use a tuple as the exception object
// In Python 2, this is problematic because only the first tuple element
// gets raised while others are discarded, potentially causing bugs
from Raise exceptionRaise, DataFlow::LocalSourceNode tupleExprSource
where
  // Issue is specific to Python 2 environments
  major_version() = 2 and
  // Source must be a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // Verify data flows from tuple to exception target
  exists(DataFlow::Node exceptionTargetNode |
    // Target node corresponds to the exception in raise statement
    exceptionTargetNode.asExpr() = exceptionRaise.getException() and
    // Confirm data flow path exists
    tupleExprSource.flowsTo(exceptionTargetNode)
  )
/* Note: Python 3 raises TypeError for tuple exceptions (handled by IllegalRaise query).
   This query specifically targets Python 2 where this behavior is allowed but problematic. */
select exceptionRaise,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"