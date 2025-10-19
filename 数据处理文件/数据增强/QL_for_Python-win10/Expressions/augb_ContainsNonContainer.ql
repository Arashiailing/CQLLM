/**
 * @name Membership test with a non-container
 * @description A membership test, such as 'item in sequence', with a non-container on the right hand side will raise a 'TypeError'.
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
predicate rhs_in_expr(ControlFlowNode rhs, Compare cmp) {
  exists(Cmpop op, int i | 
    cmp.getOp(i) = op and 
    cmp.getComparator(i) = rhs.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from ControlFlowNode nonContainerRhs, Compare cmp, Value targetValue, ClassValue containerClass, ControlFlowNode originNode
where
  rhs_in_expr(nonContainerRhs, cmp) and
  nonContainerRhs.pointsTo(_, targetValue, originNode) and
  targetValue.getClass() = containerClass and
  not Types::failedInference(containerClass, _) and
  not containerClass.hasAttribute("__contains__") and
  not containerClass.hasAttribute("__iter__") and
  not containerClass.hasAttribute("__getitem__") and
  not containerClass = ClassValue::nonetype() and
  not containerClass = Value::named("types.MappingProxyType")
select cmp, "This test may raise an Exception as the $@ may be of non-container class $@.", originNode,
  "target", containerClass, containerClass.getName()