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
 * Determines if a node serves as the right operand in an In/NotIn comparison.
 * @param rightOperandNode - The control flow node being evaluated as right operand
 * @param membershipComparison - The comparison expression containing the operation
 */
predicate isRightOperandInMembershipTest(ControlFlowNode rightOperandNode, Compare membershipComparison) {
  exists(Cmpop operation, int operandIndex |
    membershipComparison.getOp(operandIndex) = operation and 
    membershipComparison.getComparator(operandIndex) = rightOperandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare membershipComparison, 
  Value pointedToValue, 
  ClassValue rightOperandClass, 
  ControlFlowNode valueSourceNode
where
  // Identify membership tests where the node is the right operand
  isRightOperandInMembershipTest(rightOperandNode, membershipComparison) and
  
  // Resolve the node's pointed value and its class
  rightOperandNode.pointsTo(_, pointedToValue, valueSourceNode) and
  pointedToValue.getClass() = rightOperandClass and
  
  // Ensure type inference was successful
  not Types::failedInference(rightOperandClass, _) and
  
  // Check that the class lacks container-like capabilities
  (not rightOperandClass.hasAttribute("__contains__") and
   not rightOperandClass.hasAttribute("__iter__") and
   not rightOperandClass.hasAttribute("__getitem__")) and
  
  // Exclude special types that might appear as containers
  not rightOperandClass = ClassValue::nonetype() and
  not rightOperandClass = Value::named("types.MappingProxyType")
select 
  membershipComparison, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueSourceNode, "target", rightOperandClass, rightOperandClass.getName()