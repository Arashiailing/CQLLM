/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple causes only the first element to be raised as an exception,
 *              while all other elements are discarded. This can lead to unexpected behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Detects Python 2 raise statements where the exception argument originates from a tuple.
// This causes silent truncation of all but the first tuple element, potentially masking errors.
from Raise raiseNode, DataFlow::LocalSourceNode tupleSource
where
  // Restrict to Python 2 codebases where this behavior occurs
  major_version() = 2 and
  // Identify tuple expressions as the data flow source
  tupleSource.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to the raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseNode.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* Note: Python 3 raises a TypeError for tuple exceptions, handled by IllegalRaise query.
   This query specifically targets Python 2's tuple truncation behavior. */
select raiseNode,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"