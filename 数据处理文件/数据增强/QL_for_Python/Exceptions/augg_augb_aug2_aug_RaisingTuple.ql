/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple results in only the first element being raised as an exception,
 *              while all other elements are silently discarded. This can lead to unexpected behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Detects raise statements where the exception originates from a tuple expression
// In Python 2, only the first tuple element gets raised while others are discarded
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // Restrict analysis to Python 2 codebases
  major_version() = 2 and
  // Ensure source is a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to raised exception
  exists(DataFlow::Node exceptionTarget |
    exceptionTarget.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(exceptionTarget)
  )
/* Note: Python 3 treats this as a type error (handled by IllegalRaise query),
   making this specific to Python 2 environments */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"