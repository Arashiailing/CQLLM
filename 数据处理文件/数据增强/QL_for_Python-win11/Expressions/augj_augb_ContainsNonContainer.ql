/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side is a non-container.
 *              Such tests will raise a 'TypeError' at runtime because non-containers do not support membership testing.
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

// Identifies Compare nodes containing In/NotIn operations where the specified node serves as the right-hand operand
predicate rhs_in_expr(ControlFlowNode rhsOperand, Compare membershipTest) {
  exists(Cmpop op, int i | 
    membershipTest.getOp(i) = op and 
    membershipTest.getComparator(i) = rhsOperand.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from ControlFlowNode rhsOperand, Compare membershipTest, Value targetValue, ClassValue containerClass, ControlFlowNode originNode
where
  rhs_in_expr(rhsOperand, membershipTest) and
  rhsOperand.pointsTo(_, targetValue, originNode) and
  targetValue.getClass() = containerClass and
  not Types::failedInference(containerClass, _) and
  // Non-container conditions: lacks required container methods
  (
    not containerClass.hasAttribute("__contains__") and
    not containerClass.hasAttribute("__iter__") and
    not containerClass.hasAttribute("__getitem__") and
    // Exclude known safe types
    not containerClass = ClassValue::nonetype() and
    not containerClass = Value::named("types.MappingProxyType")
  )
select membershipTest, "This test may raise an Exception as the $@ may be of non-container class $@.", originNode,
  "target", containerClass, containerClass.getName()