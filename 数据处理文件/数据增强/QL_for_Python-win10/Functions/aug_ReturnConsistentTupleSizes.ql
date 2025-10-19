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
 * Determines if a function returns a tuple of specified size.
 * @param func - The function being analyzed
 * @param size - The expected tuple length
 * @param tuple - The tuple expression being returned
 */
predicate returns_tuple_of_size(Function func, int size, Tuple tuple) {
  exists(Return ret, DataFlow::Node returnNode |
    // Verify the return node belongs to the target function
    ret.getScope() = func and
    // Connect return value to data flow node
    returnNode.asExpr() = ret.getValue() and
    // Trace flow from tuple source to return node
    exists(DataFlow::LocalSourceNode sourceNode |
      sourceNode.asExpr() = tuple and
      sourceNode.flowsTo(returnNode)
    )
  |
    // Calculate tuple element count
    size = count(int index | exists(tuple.getElt(index)))
  )
}

from Function func, int s1, int s2, AstNode t1, AstNode t2
where
  // Find two distinct tuple return sizes
  returns_tuple_of_size(func, s1, t1) and
  returns_tuple_of_size(func, s2, t2) and
  // Ensure size difference exists
  s1 < s2 and
  // Exclude explicitly type-hinted functions
  not exists(func.getDefinition().(FunctionExpr).getReturns())
select 
  func, 
  func.getQualifiedName() + " returns $@ and $@.", 
  t1, "tuple of size " + s1, 
  t2, "tuple of size " + s2