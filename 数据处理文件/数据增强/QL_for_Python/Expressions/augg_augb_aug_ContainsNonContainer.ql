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
 * @param rightOperand - Node being evaluated as right operand
 * @param membershipExpr - Comparison expression containing the operation
 */
predicate isRightHandSideOfInTest(ControlFlowNode rightOperand, Compare membershipExpr) {
  exists(Cmpop operation, int operandIndex |
    membershipExpr.getOp(operandIndex) = operation and 
    membershipExpr.getComparator(operandIndex) = rightOperand.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperand, 
  Compare membershipExpr, 
  Value pointedValue, 
  ClassValue rightOperandClass, 
  ControlFlowNode originNode
where
  // Identify membership test operations
  isRightHandSideOfInTest(rightOperand, membershipExpr) and
  
  // Resolve value and class information
  rightOperand.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = rightOperandClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(rightOperandClass, _) and
  
  // Verify absence of container capabilities
  (not rightOperandClass.hasAttribute("__contains__") and
   not rightOperandClass.hasAttribute("__iter__") and
   not rightOperandClass.hasAttribute("__getitem__")) and
  
  // Exclude special container-like types
  not rightOperandClass = ClassValue::nonetype() and
  not rightOperandClass = Value::named("types.MappingProxyType")
select 
  membershipExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", rightOperandClass, rightOperandClass.getName()