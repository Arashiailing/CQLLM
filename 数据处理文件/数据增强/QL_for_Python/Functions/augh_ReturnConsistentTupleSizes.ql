/**
 * @name Returning tuples with varying lengths
 * @description Detects functions that may return tuples of different lengths, which can lead to runtime errors.
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
 * Predicate to determine if a function returns a tuple of a specific size.
 * 
 * Parameters:
 * - targetFunction: The function being analyzed
 * - tupleSize: The size of the returned tuple
 * - returnedTuple: The tuple object being returned
 */
predicate returns_tuple_of_size(Function targetFunction, int tupleSize, Tuple returnedTuple) {
  // Find a return statement that returns the tuple
  exists(Return returnStmt, DataFlow::Node returnValueNode |
    // The return value must be the same as the data flow node's expression
    returnValueNode.asExpr() = returnStmt.getValue() and
    // The return statement must belong to the target function
    returnStmt.getScope() = targetFunction and
    // There must be a data flow from the tuple to the return value
    any(DataFlow::LocalSourceNode sourceNode | sourceNode.asExpr() = returnedTuple).flowsTo(returnValueNode)
  |
    // Calculate the size of the tuple by counting its elements
    tupleSize = count(int index | exists(returnedTuple.getElt(index)))
  )
}

// Main query to identify functions returning tuples of different sizes
from Function targetFunction, int smallerSize, int largerSize, AstNode smallerTuple, AstNode largerTuple
where
  // The function returns a tuple of the smaller size
  returns_tuple_of_size(targetFunction, smallerSize, smallerTuple) and
  // The function also returns a tuple of the larger size
  returns_tuple_of_size(targetFunction, largerSize, largerTuple) and
  // Ensure the sizes are different
  smallerSize < largerSize and
  // Exclude functions with return type annotations
  not exists(targetFunction.getDefinition().(FunctionExpr).getReturns())
// Format the output message
select targetFunction, targetFunction.getQualifiedName() + " returns $@ and $@.", smallerTuple, 
  "tuple of size " + smallerSize, largerTuple, "tuple of size " + largerSize