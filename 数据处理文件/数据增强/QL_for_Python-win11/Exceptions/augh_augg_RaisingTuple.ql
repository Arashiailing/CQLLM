/**
 * @name Tuple raising in Python 2
 * @description Detects code that raises a tuple in Python 2, which results in only the first element being raised
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Detect raise statements involving tuples in Python 2
from Raise raiseExpression, DataFlow::LocalSourceNode tupleSource
where
  // Ensure we're analyzing Python 2 code
  major_version() = 2 and
  // Verify the source is a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Check data flow from tuple to the exception being raised
  exists(DataFlow::Node exceptionTarget | 
    exceptionTarget.asExpr() = raiseExpression.getException() and
    tupleSource.flowsTo(exceptionTarget)
  )
/* Note: In Python 3, raising a tuple is a type error and is handled by the IllegalRaise query. */
select raiseExpression,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"