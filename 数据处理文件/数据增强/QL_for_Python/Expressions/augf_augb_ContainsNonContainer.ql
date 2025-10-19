/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side is a non-container.
 *              Such operations raise 'TypeError' at runtime because non-container objects lack membership support.
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

// Identifies In/NotIn operations and extracts their right-hand operand
predicate get_rhs_of_membership_test(ControlFlowNode rhsNode, Compare comparisonNode) {
  exists(Cmpop op, int index | 
    comparisonNode.getOp(index) = op and 
    comparisonNode.getComparator(index) = rhsNode.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from ControlFlowNode rhsNode, Compare comparisonNode, Value pointedValue, ClassValue valueClass, ControlFlowNode sourceNode
where
  // Step 1: Identify membership test operations
  get_rhs_of_membership_test(rhsNode, comparisonNode) and
  // Step 2: Resolve value and its origin
  rhsNode.pointsTo(_, pointedValue, sourceNode) and
  // Step 3: Obtain the class of the resolved value
  pointedValue.getClass() = valueClass and
  // Step 4: Exclude cases with failed type inference
  not Types::failedInference(valueClass, _) and
  // Step 5: Exclude classes with container-like capabilities
  not (
    valueClass.hasAttribute("__contains__") or
    valueClass.hasAttribute("__iter__") or
    valueClass.hasAttribute("__getitem__")
  ) and
  // Step 6: Exclude specific known container types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select comparisonNode, "This test may raise an Exception as the $@ may be of non-container class $@.", sourceNode,
  "target", valueClass, valueClass.getName()