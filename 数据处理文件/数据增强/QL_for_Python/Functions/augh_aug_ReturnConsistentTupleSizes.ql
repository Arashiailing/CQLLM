/**
 * @name Detecting functions with inconsistent tuple return lengths
 * @description Identifies functions returning tuples of varying sizes, which may indicate design inconsistencies.
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
 * Checks if a function returns a tuple with specific dimensions.
 * @param targetFunc - The function under analysis
 * @param expectedSize - The anticipated tuple length
 * @param returnedTuple - The tuple expression being returned
 */
predicate returns_tuple_of_size(Function targetFunc, int expectedSize, Tuple returnedTuple) {
  exists(Return returnStmt, DataFlow::Node returnDataNode |
    // Verify return statement belongs to target function
    returnStmt.getScope() = targetFunc and
    // Map return value to data flow node
    returnDataNode.asExpr() = returnStmt.getValue() and
    // Trace data flow from tuple source to return point
    exists(DataFlow::LocalSourceNode tupleSourceNode |
      tupleSourceNode.asExpr() = returnedTuple and
      tupleSourceNode.flowsTo(returnDataNode)
    )
  |
    // Calculate tuple element count
    expectedSize = count(int index | exists(returnedTuple.getElt(index)))
  )
}

from Function targetFunction, int size1, int size2, AstNode tuple1, AstNode tuple2
where
  // Identify two distinct tuple return sizes
  returns_tuple_of_size(targetFunction, size1, tuple1) and
  returns_tuple_of_size(targetFunction, size2, tuple2) and
  // Ensure size difference exists
  size1 < size2 and
  // Exclude functions with explicit return type hints
  not exists(targetFunction.getDefinition().(FunctionExpr).getReturns())
select 
  targetFunction, 
  targetFunction.getQualifiedName() + " returns $@ and $@.", 
  tuple1, "tuple of size " + size1, 
  tuple2, "tuple of size " + size2