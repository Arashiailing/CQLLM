/**
 * @name Raising a tuple
 * @description Detects code that raises a tuple as an exception in Python 2,
 *              where only the first element is actually raised and others are discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// This query identifies patterns in Python 2 code where a tuple is raised as an exception.
// In Python 2, raising a tuple results in only the first element being raised,
// while all subsequent elements are silently discarded. This behavior can lead to
// unintended consequences when developers expect all tuple elements to be considered.
from Raise raiseStatement, DataFlow::LocalSourceNode tupleOrigin
where
  // Restrict to Python 2 environments, as raising a tuple in Python 3
  // results in a TypeError, which is covered by the IllegalRaise query
  major_version() = 2 and
  // Verify the data flow source is indeed a tuple expression
  tupleOrigin.asExpr() instanceof Tuple and
  // Check if the tuple expression flows to the exception part of a raise statement
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStatement.getException() and
    tupleOrigin.flowsTo(exceptionNode)
  )
/* Note: In Python 3, raising a tuple causes a TypeError, which is handled by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"