/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is not a container type, potentially raising TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/member-test-non-container
 */

import python  // Core Python language analysis capabilities
import semmle.python.pointsto.PointsTo  // Points-to analysis for value flow tracking

// Identifies comparison operations containing In/NotIn operators with specified right-hand side
predicate isMembershipTestRhs(ControlFlowNode rhsNode, Compare comparison) {
  exists(Cmpop operator, int operandIndex |
    comparison.getOp(operandIndex) = operator and
    comparison.getComparator(operandIndex) = rhsNode.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

// Analyzes membership tests where RHS may be non-container
from ControlFlowNode rhsNode, Compare membershipComparison, Value rhsValue, ClassValue rhsClass, ControlFlowNode valueOriginNode
where
  // Confirm RHS is part of membership test
  isMembershipTestRhs(rhsNode, membershipComparison) and
  // Track value flow to RHS and extract its class
  rhsNode.pointsTo(_, rhsValue, valueOriginNode) and
  rhsValue.getClass() = rhsClass and
  // Exclude cases with type inference failures
  not Types::failedInference(rhsClass, _) and
  // Verify absence of container protocol methods
  not rhsClass.hasAttribute("__contains__") and
  not rhsClass.hasAttribute("__iter__") and
  not rhsClass.hasAttribute("__getitem__") and
  // Exclude special cases with non-standard container behavior
  not rhsClass = ClassValue::nonetype() and
  not rhsClass = Value::named("types.MappingProxyType")
select membershipComparison, "Membership test may fail as the $@ belongs to non-container class $@.", valueOriginNode,
  "target", rhsClass, rhsClass.getName()