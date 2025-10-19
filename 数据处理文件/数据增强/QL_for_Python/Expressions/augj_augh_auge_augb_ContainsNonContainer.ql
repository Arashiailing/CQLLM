/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand operand 
 *              is a non-container value, potentially causing runtime 'TypeError'.
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

// Determines if a node is the right operand in membership operations (In/NotIn)
predicate isRhsOfMembershipTest(ControlFlowNode rhsNode, Compare comparisonNode) {
  exists(Cmpop operation, int operandIndex | 
    comparisonNode.getOp(operandIndex) = operation and 
    comparisonNode.getComparator(operandIndex) = rhsNode.getNode() and 
    (operation instanceof In or operation instanceof NotIn)
  )
}

from ControlFlowNode rhsNode, Compare comparisonNode, Value pointedValue, ClassValue valueClass, ControlFlowNode originNode
where
  // Verify current node is right operand of membership test
  isRhsOfMembershipTest(rhsNode, comparisonNode) and
  // Resolve value and its origin through points-to analysis
  rhsNode.pointsTo(_, pointedValue, originNode) and
  // Extract class of the resolved value
  pointedValue.getClass() = valueClass and
  // Skip cases with incomplete type inference
  not Types::failedInference(valueClass, _) and
  // Exclude classes implementing container protocols
  not (
    valueClass.hasAttribute("__contains__") or
    valueClass.hasAttribute("__iter__") or
    valueClass.hasAttribute("__getitem__")
  ) and
  // Exclude None type and special container types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select comparisonNode, "This test may raise an Exception as the $@ may be of non-container class $@.", originNode,
  "target", valueClass, valueClass.getName()