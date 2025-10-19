/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
 *              operand is not a container type, which would cause a runtime 'TypeError'.
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
 * Extracts the right-hand side operand from membership comparison operations (In/NotIn)
 * by analyzing comparison nodes and their operators.
 */
predicate isMembershipTestRhs(ControlFlowNode rhsNode, Compare comparison) {
  exists(Cmpop operator, int index |
    comparison.getOp(index) = operator and
    comparison.getComparator(index) = rhsNode.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare membershipTestNode, 
  Value targetValue, 
  ClassValue targetClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test right-hand side operands
  isMembershipTestRhs(rhsNode, membershipTestNode) and
  
  // Track value flow to determine the actual object being tested
  rhsNode.pointsTo(_, targetValue, sourceNode) and
  targetValue.getClass() = targetClass and
  
  // Exclude cases with incomplete type information
  not Types::failedInference(targetClass, _) and
  
  // Verify absence of container protocol methods
  not (
    targetClass.hasAttribute("__contains__") or
    targetClass.hasAttribute("__iter__") or
    targetClass.hasAttribute("__getitem__")
  ) and
  
  // Filter out known non-container types that might have special handling
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select 
  membershipTestNode, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", 
  targetClass, targetClass.getName()