/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, potentially causing runtime TypeError.
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
 * Identifies nodes serving as the right operand in membership test expressions.
 * @param node - Control flow node under analysis
 * @param compareNode - Comparison expression containing the membership operation
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode node, Compare compareNode) {
  exists(Cmpop operation, int operandIndex |
    compareNode.getOp(operandIndex) = operation and 
    compareNode.getComparator(operandIndex) = node.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare membershipExpr, 
  Value resolvedValue, 
  ClassValue nonContainerCls, 
  ControlFlowNode locationNode
where
  // Confirm node is right operand of membership test
  isRightOperandOfMembershipTest(rhsNode, membershipExpr) and
  
  // Resolve type information and exclude inference failures
  rhsNode.pointsTo(_, resolvedValue, locationNode) and
  resolvedValue.getClass() = nonContainerCls and
  not Types::failedInference(nonContainerCls, _) and
  
  // Verify absence of container interface methods
  (not nonContainerCls.hasAttribute("__contains__") and
   not nonContainerCls.hasAttribute("__iter__") and
   not nonContainerCls.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  (nonContainerCls != ClassValue::nonetype() and
   nonContainerCls != Value::named("types.MappingProxyType"))
select 
  membershipExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  locationNode, "target", nonContainerCls, nonContainerCls.getName()