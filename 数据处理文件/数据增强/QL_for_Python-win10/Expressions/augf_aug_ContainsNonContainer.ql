/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, which would raise a 'TypeError' at runtime.
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
 * Holds if `node` is the right operand in an In/NotIn comparison.
 * @param node - The control flow node being evaluated
 * @param compareNode - The comparison expression containing the operation
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
  Compare membershipTest, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode originNode
where
  // Identify membership test operations with node as right operand
  isRightOperandOfMembershipTest(rhsNode, membershipTest) and
  
  // Resolve the node's pointed value and its class
  rhsNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = valueClass and
  
  // Exclude cases where type inference failed
  not Types::failedInference(valueClass, _) and
  
  // Verify the class lacks container-like capabilities
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Exclude special types that might appear as containers
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  membershipTest, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", valueClass, valueClass.getName()