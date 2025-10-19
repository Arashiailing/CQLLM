/**
 * @name Raising a tuple in Python 2
 * @description Detects instances where a tuple is raised as an exception in Python 2.
 *              This behavior leads to only the first element being raised as an exception,
 *              while all other elements are silently discarded, potentially causing unexpected runtime behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// This query identifies raise statements where the exception being raised originates from a tuple expression.
// In Python 2, this causes only the first element of the tuple to be raised as an exception, while
// discarding all other elements, which can lead to unexpected behavior.
from Raise exceptionRaise, DataFlow::LocalSourceNode originatingTuple
where
  // Constraint: This issue is specific to Python 2 environments
  major_version() = 2 and
  // The source must be a tuple expression
  originatingTuple.asExpr() instanceof Tuple and
  // Verify data flow from the tuple to the raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = exceptionRaise.getException() and
    originatingTuple.flowsTo(exceptionNode)
  )
/* Note: In Python 3, raising a tuple results in a type error, which is handled by the IllegalRaise query.
   Therefore, this query is specifically targeted at Python 2 codebases. */
select exceptionRaise,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  originatingTuple, "tuple"