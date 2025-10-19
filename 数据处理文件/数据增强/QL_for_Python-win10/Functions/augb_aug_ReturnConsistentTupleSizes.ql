/**
 * @name Returning tuples with varying lengths
 * @description Detects functions returning tuples of inconsistent lengths, which may indicate design issues.
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
 * Check whether a function returns a tuple with the given size.
 * @param targetFunc - The function being analyzed
 * @param tupleSize - The expected tuple length
 * @param returnedTuple - The tuple expression being returned
 */
predicate returns_tuple_of_size(Function targetFunc, int tupleSize, Tuple returnedTuple) {
  exists(Return returnStmt, DataFlow::Node returnFlowNode |
    // Verify the return statement belongs to the target function
    returnStmt.getScope() = targetFunc and
    // Connect return value to data flow node
    returnFlowNode.asExpr() = returnStmt.getValue() and
    // Trace flow from tuple source to return node
    exists(DataFlow::LocalSourceNode tupleSourceNode |
      tupleSourceNode.asExpr() = returnedTuple and
      tupleSourceNode.flowsTo(returnFlowNode)
    )
  |
    // Calculate tuple element count
    tupleSize = count(int index | exists(returnedTuple.getElt(index)))
  )
}

from Function targetFunction, int smallerSize, int largerSize, AstNode smallerTuple, AstNode largerTuple
where
  // Find two distinct tuple return sizes
  returns_tuple_of_size(targetFunction, smallerSize, smallerTuple) and
  returns_tuple_of_size(targetFunction, largerSize, largerTuple) and
  // Ensure size difference exists
  smallerSize < largerSize and
  // Exclude explicitly type-hinted functions
  not exists(targetFunction.getDefinition().(FunctionExpr).getReturns())
select 
  targetFunction, 
  targetFunction.getQualifiedName() + " returns $@ and $@.", 
  smallerTuple, "tuple of size " + smallerSize, 
  largerTuple, "tuple of size " + largerSize