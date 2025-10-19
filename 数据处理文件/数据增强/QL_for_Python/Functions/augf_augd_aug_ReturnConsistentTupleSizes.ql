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
 * Determines whether a function returns a tuple of a specific size.
 * @param func - The function being analyzed.
 * @param expectedSize - The expected size of the returned tuple.
 * @param returnedTuple - The tuple expression that is returned.
 */
predicate returns_tuple_of_size(Function func, int expectedSize, Tuple returnedTuple) {
  exists(Return retStmt, DataFlow::Node retFlowNode |
    // Ensure the return statement is within the analyzed function
    retStmt.getScope() = func and
    // Map the return value to a data flow node
    retFlowNode.asExpr() = retStmt.getValue() and
    // Trace data flow from the tuple source to the return node
    exists(DataFlow::LocalSourceNode tupleSrc |
      tupleSrc.asExpr() = returnedTuple and
      tupleSrc.flowsTo(retFlowNode)
    )
  |
    // Calculate the number of elements in the tuple
    expectedSize = count(int index | exists(returnedTuple.getElt(index)))
  )
}

from Function func, int firstSize, int secondSize, AstNode firstTuple, AstNode secondTuple
where
  // Identify distinct tuple return sizes from same function
  returns_tuple_of_size(func, firstSize, firstTuple) and
  returns_tuple_of_size(func, secondSize, secondTuple) and
  // Ensure size variation exists
  firstSize < secondSize and
  // Exclude functions with explicit return type hints
  not exists(func.getDefinition().(FunctionExpr).getReturns())
select 
  func, 
  func.getQualifiedName() + " returns $@ and $@.", 
  firstTuple, "tuple of size " + firstSize, 
  secondTuple, "tuple of size " + secondSize