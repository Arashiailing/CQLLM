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
 * Identifies functions that return a tuple with a specific number of elements.
 * @param targetFunction - The function under analysis
 * @param tupleLength - The number of elements in the returned tuple
 * @param returnedTuple - The tuple expression that is returned
 */
predicate returns_tuple_of_size(Function targetFunction, int tupleLength, Tuple returnedTuple) {
  exists(Return returnStmt, DataFlow::Node returnValueNode |
    // Ensure the return statement belongs to the function being analyzed
    returnStmt.getScope() = targetFunction and
    // Map the return value to a data flow node for analysis
    returnValueNode.asExpr() = returnStmt.getValue() and
    // Trace the data flow from the tuple source to the return value
    exists(DataFlow::LocalSourceNode tupleSourceNode |
      tupleSourceNode.asExpr() = returnedTuple and
      tupleSourceNode.flowsTo(returnValueNode)
    )
  |
    // Count the number of elements in the tuple
    tupleLength = count(int index | exists(returnedTuple.getElt(index)))
  )
}

from Function targetFunction, int firstTupleLength, int secondTupleLength, AstNode firstTuple, AstNode secondTuple
where
  // Identify two tuples of different lengths returned by the same function
  returns_tuple_of_size(targetFunction, firstTupleLength, firstTuple) and
  returns_tuple_of_size(targetFunction, secondTupleLength, secondTuple) and
  // Ensure we're dealing with tuples of different sizes
  firstTupleLength < secondTupleLength and
  // Exclude functions with explicit return type annotations
  not exists(targetFunction.getDefinition().(FunctionExpr).getReturns())
select 
  targetFunction, 
  targetFunction.getQualifiedName() + " returns $@ and $@.", 
  firstTuple, "tuple of size " + firstTupleLength, 
  secondTuple, "tuple of size " + secondTupleLength