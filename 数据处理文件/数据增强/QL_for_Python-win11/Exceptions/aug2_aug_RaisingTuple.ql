/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple will result in only the first element being raised as an exception,
 *              while all other elements in the tuple are silently discarded. This can lead to unexpected behavior.
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
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // This issue only occurs in Python 2
  major_version() = 2 and
  // The source must be a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // There must be data flow from the tuple to the raised exception
  exists(DataFlow::Node raisedExceptionNode |
    raisedExceptionNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(raisedExceptionNode)
  )
/* Note: In Python 3, raising a tuple results in a type error, which is handled by the IllegalRaise query.
   Therefore, this query is specifically targeted at Python 2 codebases. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"