/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand side 
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
 * Identifies nodes serving as the right operand in In/NotIn comparisons.
 * @param operandNode - The control flow node being evaluated
 * @param comparisonExpr - The comparison expression containing the operation
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode operandNode, Compare comparisonExpr) {
  exists(Cmpop operation, int operandIndex |
    comparisonExpr.getOp(operandIndex) = operation and 
    comparisonExpr.getComparator(operandIndex) = operandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare membershipTest, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode originNode
where
  // Verify node is right operand in membership test
  isRightOperandOfMembershipTest(rightOperandNode, membershipTest) and
  
  // Resolve pointed value and its class
  rightOperandNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = valueClass and
  
  // Exclude type inference failures
  not Types::failedInference(valueClass, _) and
  
  // Check for missing container capabilities
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Exclude special container-like types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  membershipTest, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", valueClass, valueClass.getName()