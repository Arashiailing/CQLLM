/**
 * @name Raising a tuple in Python 2
 * @description Detects locations where a tuple is raised as an exception in Python 2.
 *              In Python 2, raising a tuple only propagates the first element as an exception,
 *              while silently discarding all other elements. This leads to unexpected
 *              runtime behavior and potential bugs.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// This query identifies raise statements in Python 2 where the exception originates
// from a tuple expression. Such behavior causes only the first tuple element to be
// raised, while all other elements are discarded.
from Raise raiseNode, DataFlow::LocalSourceNode tupleExprNode
where
  // Restrict analysis to Python 2 environments
  major_version() = 2 and
  // Confirm the source node represents a tuple expression
  tupleExprNode.asExpr() instanceof Tuple and
  // Verify data flows from the tuple to the raised exception
  tupleExprNode.flowsTo(DataFlow::exprNode(raiseNode.getException()))
/* Note: Python 3 handles tuple raising differently by throwing a TypeError,
   which is covered by the IllegalRaise query. This analysis specifically targets
   Python 2 codebases where tuple raising is syntactically valid but semantically
   problematic. */
select raiseNode,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprNode, "tuple"