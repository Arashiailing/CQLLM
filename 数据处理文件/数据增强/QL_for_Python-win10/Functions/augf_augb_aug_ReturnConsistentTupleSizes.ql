/**
 * @name Inconsistent tuple return lengths
 * @description Identifies functions returning tuples with varying lengths, suggesting potential design flaws.
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
 * @param func - The analyzed function
 * @param size - Expected tuple length
 * @param tupleExpr - Returned tuple expression
 */
predicate returns_tuple_of_size(Function func, int size, Tuple tupleExpr) {
  exists(Return retStmt, DataFlow::Node retNode |
    retStmt.getScope() = func and
    retNode.asExpr() = retStmt.getValue() and
    exists(DataFlow::LocalSourceNode sourceNode |
      sourceNode.asExpr() = tupleExpr and
      sourceNode.flowsTo(retNode)
    )
  ) and
  size = count(int idx | exists(tupleExpr.getElt(idx)))
}

from Function func, int minSize, int maxSize, AstNode minTuple, AstNode maxTuple
where
  returns_tuple_of_size(func, minSize, minTuple) and
  returns_tuple_of_size(func, maxSize, maxTuple) and
  minSize < maxSize and
  not exists(func.getDefinition().(FunctionExpr).getReturns())
select 
  func, 
  func.getQualifiedName() + " returns $@ and $@.", 
  minTuple, "tuple of size " + minSize, 
  maxTuple, "tuple of size " + maxSize