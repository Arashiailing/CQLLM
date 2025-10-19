/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
 *              is not a container type, which can cause a TypeError at runtime.
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
 * Identifies nodes serving as the right operand in membership tests.
 * @param operandNode - Control flow node being evaluated
 * @param comparisonNode - Comparison expression containing the membership test
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode operandNode, Compare comparisonNode) {
  exists(Cmpop operation, int index |
    comparisonNode.getOp(index) = operation and 
    comparisonNode.getComparator(index) = operandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightHandOperand, 
  Compare membershipComparison, 
  Value pointedValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Verify node is right operand of membership test
  isRightOperandOfMembershipTest(rightHandOperand, membershipComparison) and
  
  // Resolve pointed value and class information
  rightHandOperand.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = nonContainerClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(nonContainerClass, _) and
  
  // Confirm class lacks container interface methods
  not nonContainerClass.hasAttribute("__contains__") and
  not nonContainerClass.hasAttribute("__iter__") and
  not nonContainerClass.hasAttribute("__getitem__") and
  
  // Exclude special pseudo-container types
  not nonContainerClass = ClassValue::nonetype() and
  not nonContainerClass = Value::named("types.MappingProxyType")
select 
  membershipComparison, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", nonContainerClass, nonContainerClass.getName()