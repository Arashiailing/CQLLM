/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side 
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
 * Identifies nodes that serve as the right operand in an In/NotIn comparison operation.
 * @param rightOperand - The control flow node being evaluated as right operand
 * @param membershipTest - The comparison expression containing the membership test
 */
predicate isRightOperandInMembershipTest(ControlFlowNode rightOperand, Compare membershipTest) {
  exists(Cmpop operation, int operandIndex |
    membershipTest.getOp(operandIndex) = operation and 
    membershipTest.getComparator(operandIndex) = rightOperand.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare membershipTestExpr, 
  Value pointedToValue, 
  ClassValue rightOperandClass, 
  ControlFlowNode valueSourceNode
where
  // Identify membership tests and get the right operand
  isRightOperandInMembershipTest(rightOperandNode, membershipTestExpr) and
  
  // Resolve the value and its class for the right operand
  rightOperandNode.pointsTo(_, pointedToValue, valueSourceNode) and
  pointedToValue.getClass() = rightOperandClass and
  
  // Ensure type inference was successful
  not Types::failedInference(rightOperandClass, _) and
  
  // Check that the class lacks container-like capabilities and is not a special container type
  (not rightOperandClass.hasAttribute("__contains__") and
   not rightOperandClass.hasAttribute("__iter__") and
   not rightOperandClass.hasAttribute("__getitem__")) and
  not rightOperandClass = ClassValue::nonetype() and
  not rightOperandClass = Value::named("types.MappingProxyType")
select 
  membershipTestExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueSourceNode, "target", rightOperandClass, rightOperandClass.getName()