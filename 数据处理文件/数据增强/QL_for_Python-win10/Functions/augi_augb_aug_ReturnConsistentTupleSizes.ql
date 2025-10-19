/**
 * @name Inconsistent tuple return sizes
 * @description Identifies functions returning tuples with inconsistent lengths, indicating potential design flaws.
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
 * Determines if a function returns a tuple of specified size.
 * @param func - The function under analysis
 * @param size - The expected tuple length
 * @param tupleExpr - The returned tuple expression
 */
predicate returns_tuple_of_size(Function func, int size, Tuple tupleExpr) {
  exists(Return retStmt, DataFlow::Node retNode |
    // Confirm return statement belongs to the analyzed function
    retStmt.getScope() = func and
    // Map return value to data flow node
    retNode.asExpr() = retStmt.getValue() and
    // Track data flow from tuple source to return point
    exists(DataFlow::LocalSourceNode sourceNode |
      sourceNode.asExpr() = tupleExpr and
      sourceNode.flowsTo(retNode)
    )
  |
    // Compute tuple element count
    size = count(int idx | exists(tupleExpr.getElt(idx)))
  )
}

from Function func, int smallSize, int largeSize, AstNode smallTuple, AstNode largeTuple
where
  // Identify two distinct tuple return sizes
  returns_tuple_of_size(func, smallSize, smallTuple) and
  returns_tuple_of_size(func, largeSize, largeTuple) and
  // Ensure size difference exists
  smallSize < largeSize and
  // Exclude functions with explicit return type hints
  not exists(func.getDefinition().(FunctionExpr).getReturns())
select 
  func, 
  func.getQualifiedName() + " returns $@ and $@.", 
  smallTuple, "tuple of size " + smallSize, 
  largeTuple, "tuple of size " + largeSize