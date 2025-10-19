/**
 * @name Raising a tuple
 * @description Identifies Python 2 code patterns where a tuple is raised as an exception,
 *              leading to only the first element being raised while others are discarded.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// This query targets Python 2 environments to detect code patterns where tuples are raised as exceptions
// In Python 2, raising a tuple results in only the first element being raised, with all other elements ignored
// This behavior contradicts developer expectations, as they might anticipate the entire tuple being raised
from Raise raiseStmt, DataFlow::LocalSourceNode tupleOrigin
where
  // Verify that the data flow source originates from a tuple expression
  tupleOrigin.asExpr() instanceof Tuple and
  // Restrict the analysis to Python 2 environments, as Python 3 raises a TypeError for tuple exceptions
  major_version() = 2 and
  // Confirm that the tuple expression flows into the exception part of a raise statement
  exists(DataFlow::Node exceptionPart | 
    exceptionPart.asExpr() = raiseStmt.getException() and
    tupleOrigin.flowsTo(exceptionPart)
  )
/* Note: In Python 3, raising a tuple causes a TypeError, which is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"