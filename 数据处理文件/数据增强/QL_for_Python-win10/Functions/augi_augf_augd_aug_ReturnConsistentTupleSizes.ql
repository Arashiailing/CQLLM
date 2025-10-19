/**
 * @name Inconsistent Tuple Return Sizes
 * @description Detects functions that return tuples of different sizes, which may indicate design inconsistencies.
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
 * Determines if a function returns a tuple of a specific size.
 * @param analyzedFunc - The function being analyzed.
 * @param tupleSize - The expected size of the returned tuple.
 * @param returnedTupleExpr - The tuple expression that is returned.
 */
predicate returns_tuple_of_size(Function analyzedFunc, int tupleSize, Tuple returnedTupleExpr) {
  exists(Return returnStmt, DataFlow::Node returnFlowNode |
    // Ensure the return statement is within the analyzed function
    returnStmt.getScope() = analyzedFunc and
    // Map the return value to a data flow node
    returnFlowNode.asExpr() = returnStmt.getValue() and
    // Trace data flow from the tuple source to the return node
    exists(DataFlow::LocalSourceNode tupleSourceNode |
      tupleSourceNode.asExpr() = returnedTupleExpr and
      tupleSourceNode.flowsTo(returnFlowNode)
    )
  |
    // Calculate the number of elements in the tuple
    tupleSize = count(int index | exists(returnedTupleExpr.getElt(index)))
  )
}

from Function analyzedFunc, int smallerSize, int largerSize, AstNode smallerTuple, AstNode largerTuple
where
  // Identify distinct tuple return sizes from same function
  returns_tuple_of_size(analyzedFunc, smallerSize, smallerTuple) and
  returns_tuple_of_size(analyzedFunc, largerSize, largerTuple) and
  // Ensure size variation exists
  smallerSize < largerSize and
  // Exclude functions with explicit return type hints
  not exists(analyzedFunc.getDefinition().(FunctionExpr).getReturns())
select 
  analyzedFunc, 
  analyzedFunc.getQualifiedName() + " returns $@ and $@.", 
  smallerTuple, "tuple of size " + smallerSize, 
  largerTuple, "tuple of size " + largerSize