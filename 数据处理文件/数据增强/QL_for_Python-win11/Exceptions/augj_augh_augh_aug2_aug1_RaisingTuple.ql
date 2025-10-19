/**
 * @name Raising a tuple
 * @description Identifies instances where a tuple is raised as an exception in Python 2,
 *              which results in only the first element being raised (recursively) and
 *              all other elements being discarded.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements in Python 2 code where a tuple is being raised as an exception
// This behavior is specific to Python 2, where raising a tuple leads to only the first
// element (recursively) being raised, with all other elements being discarded
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSource
where
  // Confirm the code is executing in a Python 2 environment
  major_version() = 2 and
  // Validate that the data flow source is indeed a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Verify that the tuple expression flows to the exception part of a raise statement
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStatement.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* Note: In Python 3, attempting to raise a tuple results in a TypeError,
   which is already handled by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"