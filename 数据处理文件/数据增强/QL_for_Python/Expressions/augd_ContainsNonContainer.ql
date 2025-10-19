/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is not a container type, which would raise a 'TypeError' at runtime.
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
 * Identifies comparison nodes containing membership tests (In/NotIn operations)
 * and extracts the right-hand side operand being tested for membership.
 */
predicate isMembershipTestRhs(ControlFlowNode rhsNode, Compare comparison) {
  exists(Cmpop operator, int index |
    comparison.getOp(index) = operator and
    comparison.getComparator(index) = rhsNode.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode nonContainerNode, 
  Compare comparisonNode, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode originNode
where
  isMembershipTestRhs(nonContainerNode, comparisonNode) and
  nonContainerNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = valueClass and
  // Exclude cases with type inference failures
  not Types::failedInference(valueClass, _) and
  // Verify the class lacks container-specific methods
  not (
    valueClass.hasAttribute("__contains__") or
    valueClass.hasAttribute("__iter__") or
    valueClass.hasAttribute("__getitem__")
  ) and
  // Exclude special known non-container types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  comparisonNode, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", 
  valueClass, valueClass.getName()