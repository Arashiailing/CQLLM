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

// Identifies Python 2 raise statements that use tuples as exception arguments.
// In Python 2, only the first element of the tuple is raised, silently discarding the rest.
from Raise raiseStmt, DataFlow::LocalSourceNode tupleOrigin
where
  // Limit analysis to Python 2 codebases where tuple truncation occurs
  major_version() = 2 and
  // Confirm the source node represents a tuple expression
  tupleOrigin.asExpr() instanceof Tuple and
  // Establish data flow path from tuple to the exception argument
  exists(DataFlow::Node exceptionArg |
    exceptionArg.asExpr() = raiseStmt.getException() and
    tupleOrigin.flowsTo(exceptionArg)
  )
/* Note: Python 3 handles tuple exceptions differently by raising a TypeError,
   which is covered by the IllegalRaise query. This analysis specifically targets
   the tuple truncation behavior unique to Python 2. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"