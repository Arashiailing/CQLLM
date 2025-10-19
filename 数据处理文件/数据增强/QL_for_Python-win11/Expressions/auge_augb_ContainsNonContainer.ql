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
predicate is_rhs_of_membership_test(ControlFlowNode rhsNode, Compare compareNode) {
  exists(Cmpop op, int idx | 
    compareNode.getOp(idx) = op and 
    compareNode.getComparator(idx) = rhsNode.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from ControlFlowNode rhsNode, Compare compareNode, Value pointedValue, ClassValue valueClass, ControlFlowNode sourceNode
where
  // Identify membership test with the current node as right-hand operand
  is_rhs_of_membership_test(rhsNode, compareNode) and
  // Get the value and its source node through points-to analysis
  rhsNode.pointsTo(_, pointedValue, sourceNode) and
  // Extract the class of the pointed value
  pointedValue.getClass() = valueClass and
  // Exclude cases with failed type inference
  not Types::failedInference(valueClass, _) and
  // Exclude classes that implement container-like methods
  not (
    valueClass.hasAttribute("__contains__") or
    valueClass.hasAttribute("__iter__") or
    valueClass.hasAttribute("__getitem__")
  ) and
  // Exclude None type and special container types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select compareNode, "This test may raise an Exception as the $@ may be of non-container class $@.", sourceNode,
  "target", valueClass, valueClass.getName()