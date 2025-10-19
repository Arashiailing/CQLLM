/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, which would raise a 'TypeError' at runtime.
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
 * @param operandNode - The node being evaluated as right operand
 * @param membershipTest - The comparison expression containing the operation
 */
predicate isRightOperandInMembershipTest(ControlFlowNode operandNode, Compare membershipTest) {
  exists(Cmpop operation, int index |
    membershipTest.getOp(index) = operation and 
    membershipTest.getComparator(index) = operandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare membershipTest, 
  Value targetValue, 
  ClassValue targetClass, 
  ControlFlowNode valueSource
where
  // Identify membership tests where the node is the right operand
  isRightOperandInMembershipTest(rightOperandNode, membershipTest) and
  
  // Resolve the object pointed to by the node and its class
  rightOperandNode.pointsTo(_, targetValue, valueSource) and
  targetValue.getClass() = targetClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(targetClass, _) and
  
  // Verify absence of container-like methods
  (not targetClass.hasAttribute("__contains__") and
   not targetClass.hasAttribute("__iter__") and
   not targetClass.hasAttribute("__getitem__")) and
  
  // Exclude special non-container types
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select 
  membershipTest, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueSource, "target", targetClass, targetClass.getName()