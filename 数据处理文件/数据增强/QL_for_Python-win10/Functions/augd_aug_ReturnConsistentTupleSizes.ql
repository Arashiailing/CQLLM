/**
 * @name Returning tuples with varying lengths
 * @description Identifies functions returning tuples of inconsistent sizes, potentially indicating design flaws.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       quality
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-tuple-returns
 */

import python
import semmle.python.ApiGraphs

/**
 * Verifies if a function returns a tuple with a specific element count.
 * @param function - The analyzed function
 * @param tupleSize - The expected tuple length
 * @param tupleExpr - The tuple expression being returned
 */
predicate returns_tuple_of_size(Function function, int tupleSize, Tuple tupleExpr) {
  exists(Return returnStmt, DataFlow::Node returnFlowNode |
    // Confirm the return statement belongs to the target function
    returnStmt.getScope() = function and
    // Map return value to data flow node
    returnFlowNode.asExpr() = returnStmt.getValue() and
    // Track data flow from tuple source to return node
    exists(DataFlow::LocalSourceNode tupleSource |
      tupleSource.asExpr() = tupleExpr and
      tupleSource.flowsTo(returnFlowNode)
    )
  |
    // Compute tuple element count
    tupleSize = count(int index | exists(tupleExpr.getElt(index)))
  )
}

from Function function, int size1, int size2, AstNode tuple1, AstNode tuple2
where
  // Identify distinct tuple return sizes from same function
  returns_tuple_of_size(function, size1, tuple1) and
  returns_tuple_of_size(function, size2, tuple2) and
  // Ensure size variation exists
  size1 < size2 and
  // Exclude functions with explicit return type hints
  not exists(function.getDefinition().(FunctionExpr).getReturns())
select 
  function, 
  function.getQualifiedName() + " returns $@ and $@.", 
  tuple1, "tuple of size " + size1, 
  tuple2, "tuple of size " + size2