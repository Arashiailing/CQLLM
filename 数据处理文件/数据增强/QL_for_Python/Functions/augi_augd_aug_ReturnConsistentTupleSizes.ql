/**
 * @name Inconsistent tuple return lengths
 * @description Detects functions returning tuples with varying sizes, which may indicate design inconsistencies.
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
 * Determines if a function returns a tuple with specific element count.
 * @param targetFunc - The function under analysis
 * @param tupleLength - The expected tuple length
 * @param returnedTuple - The tuple expression being returned
 */
predicate returns_tuple_of_size(Function targetFunc, int tupleLength, Tuple returnedTuple) {
  exists(Return retStmt, DataFlow::Node retFlowNode |
    // Verify return statement belongs to target function
    retStmt.getScope() = targetFunc and
    // Map return value to data flow node
    retFlowNode.asExpr() = retStmt.getValue() and
    // Track data flow from tuple source to return node
    exists(DataFlow::LocalSourceNode tupleSrc |
      tupleSrc.asExpr() = returnedTuple and
      tupleSrc.flowsTo(retFlowNode)
    )
  |
    // Calculate tuple element count
    tupleLength = count(int idx | exists(returnedTuple.getElt(idx)))
  )
}

from Function targetFunc, int firstSize, int secondSize, AstNode firstTuple, AstNode secondTuple
where
  // Identify distinct tuple return sizes from same function
  returns_tuple_of_size(targetFunc, firstSize, firstTuple) and
  returns_tuple_of_size(targetFunc, secondSize, secondTuple) and
  // Ensure size variation exists
  firstSize < secondSize and
  // Exclude functions with explicit return type hints
  not exists(targetFunc.getDefinition().(FunctionExpr).getReturns())
select 
  targetFunc, 
  targetFunc.getQualifiedName() + " returns $@ and $@.", 
  firstTuple, "tuple of size " + firstSize, 
  secondTuple, "tuple of size " + secondSize