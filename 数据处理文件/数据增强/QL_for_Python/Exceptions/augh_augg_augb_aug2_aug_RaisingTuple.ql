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

// This query identifies raise statements that use tuple expressions as exceptions
// In Python 2, this behavior causes only the first tuple element to be raised,
// which differs from Python 3 where this would be a type error
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSourceNode
where
  // Limit the analysis scope to Python 2 codebases only
  major_version() = 2 and
  // Confirm the source node represents a tuple expression
  tupleSourceNode.asExpr() instanceof Tuple and
  // Establish data flow connection between the tuple and the raised exception
  exists(DataFlow::Node exceptionDestNode |
    exceptionDestNode.asExpr() = raiseStatement.getException() and
    tupleSourceNode.flowsTo(exceptionDestNode)
  )
/* Important: This behavior is specific to Python 2. In Python 3, raising a tuple
   results in a TypeError, which is covered by the IllegalRaise query */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSourceNode, "tuple"