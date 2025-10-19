/**
 * @name Tuple raising in Python 2
 * @description When raising a tuple in Python 2, only the first element is actually raised as an exception,
 *              while the remaining elements are silently ignored. This behavior can cause unexpected program execution.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Detects raise statements that originate from a tuple expression
// In Python 2, this leads to only the first element being raised as an exception
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // Restrict to Python 2 environments
  major_version() = 2 and
  // Ensure the source is a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // Check data flow path from tuple to the exception being raised
  exists(DataFlow::Node raisedException |
    raisedException.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(raisedException)
  )
/* Note: Python 3 treats this as a type error (addressed by the IllegalRaise query),
   hence this check is specific to Python 2 codebases */
select raiseStmt,
  "Raising a $@ will cause only the first element (recursively) to be raised as an exception, with all other elements being discarded.",
  tupleExprSource, "tuple"