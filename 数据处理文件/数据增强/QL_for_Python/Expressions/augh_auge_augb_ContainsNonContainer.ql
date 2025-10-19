/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand operand 
 *              is a non-container value, which may raise a 'TypeError' at runtime.
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

// Identifies Compare nodes with In/NotIn operations where the specified node is the right-hand operand
predicate isRightOperandOfMembershipTest(ControlFlowNode rightOperandNode, Compare membershipTestNode) {
  exists(Cmpop op, int idx | 
    membershipTestNode.getOp(idx) = op and 
    membershipTestNode.getComparator(idx) = rightOperandNode.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from ControlFlowNode rightOperandNode, Compare membershipTestNode, Value targetValue, ClassValue targetClass, ControlFlowNode valueSourceNode
where
  // Identify membership test with the current node as right-hand operand
  isRightOperandOfMembershipTest(rightOperandNode, membershipTestNode) and
  // Get the value and its source node through points-to analysis
  rightOperandNode.pointsTo(_, targetValue, valueSourceNode) and
  // Extract the class of the pointed value
  targetValue.getClass() = targetClass and
  // Exclude cases with failed type inference
  not Types::failedInference(targetClass, _) and
  // Exclude classes that implement container-like methods
  not (
    targetClass.hasAttribute("__contains__") or
    targetClass.hasAttribute("__iter__") or
    targetClass.hasAttribute("__getitem__")
  ) and
  // Exclude None type and special container types
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select membershipTestNode, "This test may raise an Exception as the $@ may be of non-container class $@.", valueSourceNode,
  "target", targetClass, targetClass.getName()