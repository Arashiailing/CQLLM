/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, which may cause runtime TypeError.
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
 * Identifies nodes acting as the right operand in membership tests.
 * @param rhsNode - Control flow node being evaluated
 * @param cmpExpr - Comparison expression containing the membership test
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode rhsNode, Compare cmpExpr) {
  exists(Cmpop operation, int index |
    cmpExpr.getOp(index) = operation and 
    cmpExpr.getComparator(index) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedValue, 
  ClassValue nonContainerCls, 
  ControlFlowNode sourceNode
where
  // Confirm node is right operand of membership test
  isRightOperandOfMembershipTest(rhsNode, cmpExpr) and
  
  // Resolve pointed value and class information
  rhsNode.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = nonContainerCls and
  
  // Exclude cases with failed type inference
  not Types::failedInference(nonContainerCls, _) and
  
  // Verify class lacks container interface methods
  (not nonContainerCls.hasAttribute("__contains__") and
   not nonContainerCls.hasAttribute("__iter__") and
   not nonContainerCls.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  not nonContainerCls = ClassValue::nonetype() and
  not nonContainerCls = Value::named("types.MappingProxyType")
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", nonContainerCls, nonContainerCls.getName()