/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side is not a container type, which may raise TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/member-test-non-container
 */

import python  // Provides core Python language analysis capabilities
import semmle.python.pointsto.PointsTo  // Enables points-to analysis for value tracking

// Identifies comparison operations containing In/NotIn operators with specified right-hand side
predicate isMembershipTestRhs(ControlFlowNode rhsNode, Compare comparison) {
  exists(Cmpop operator, int operandIndex |
    comparison.getOp(operandIndex) = operator and
    comparison.getComparator(operandIndex) = rhsNode.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

// Analyzes membership tests where RHS may be non-container
from ControlFlowNode nonContainerNode, Compare comparison, Value targetValue, ClassValue targetClass, ControlFlowNode sourceNode
where
  isMembershipTestRhs(nonContainerNode, comparison) and  // Confirm RHS is part of membership test
  nonContainerNode.pointsTo(_, targetValue, sourceNode) and  // Track value flow to RHS
  targetValue.getClass() = targetClass and  // Extract class of RHS value
  // Exclude cases with type inference failures
  not Types::failedInference(targetClass, _) and
  // Verify absence of container protocol methods
  not targetClass.hasAttribute("__contains__") and
  not targetClass.hasAttribute("__iter__") and
  not targetClass.hasAttribute("__getitem__") and
  // Exclude special cases with non-standard container behavior
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select comparison, "Membership test may fail as the $@ belongs to non-container class $@.", sourceNode,
  "target", targetClass, targetClass.getName()