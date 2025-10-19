/**
 * @name Membership test with non-container type
 * @description Finds membership tests (using 'in' or 'not in') where the right-hand operand
 *              has a type that does not support container operations, which may lead to a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/member-test-non-container
 */

import python
import semmle.python.pointsto.PointsTo

/**
 * Holds if `rhsNode` is the right-hand side operand of a membership test ('in' or 'not in')
 * in the comparison expression `cmpExpr`.
 * @param rhsNode - The control flow node being evaluated as the right operand.
 * @param cmpExpr - The comparison expression that contains the membership test.
 */
predicate isRightHandSideOfInTest(ControlFlowNode rhsNode, Compare cmpExpr) {
  exists(Cmpop operation, int operandIndex |
    cmpExpr.getOp(operandIndex) = operation and 
    cmpExpr.getComparator(operandIndex) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedVal, 
  ClassValue nonContainerCls, 
  ControlFlowNode origin
where
  // Verify node is right operand of membership test
  isRightHandSideOfInTest(rhsNode, cmpExpr) and
  
  // Resolve pointed value and class information
  rhsNode.pointsTo(_, pointedVal, origin) and
  pointedVal.getClass() = nonContainerCls and
  
  // Exclude cases with failed type inference
  not Types::failedInference(nonContainerCls, _) and
  
  // Confirm class lacks container interface methods
  (not nonContainerCls.hasAttribute("__contains__") and
   not nonContainerCls.hasAttribute("__iter__") and
   not nonContainerCls.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  (not nonContainerCls = ClassValue::nonetype() and
   not nonContainerCls = Value::named("types.MappingProxyType"))
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  origin, "target", nonContainerCls, nonContainerCls.getName()