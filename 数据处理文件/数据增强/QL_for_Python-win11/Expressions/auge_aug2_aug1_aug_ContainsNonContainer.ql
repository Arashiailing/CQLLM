/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, leading to a runtime 'TypeError'.
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
 * Identifies nodes that serve as the right-hand side operands in In/NotIn comparison operations.
 * @param rhsNode - The control flow node being evaluated as the right operand
 * @param comparisonExpr - The comparison expression containing the membership test
 */
predicate isRhsOperandInMembershipTest(ControlFlowNode rhsNode, Compare comparisonExpr) {
  exists(Cmpop membershipOperator, int operandIndex |
    comparisonExpr.getOp(operandIndex) = membershipOperator and 
    comparisonExpr.getComparator(operandIndex) = rhsNode.getNode() and
    (membershipOperator instanceof In or membershipOperator instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsOperand, 
  Compare comparisonExpr, 
  Value targetValue, 
  ClassValue targetClass, 
  ControlFlowNode valueOrigin
where
  // Confirm the node is the right operand in a membership test
  isRhsOperandInMembershipTest(rhsOperand, comparisonExpr) and
  
  // Resolve the node's value and determine its class
  rhsOperand.pointsTo(_, targetValue, valueOrigin) and
  targetValue.getClass() = targetClass and
  
  // Skip cases where type inference failed
  not Types::failedInference(targetClass, _) and
  
  // Verify the class lacks container capabilities
  not targetClass.hasAttribute("__contains__") and
  not targetClass.hasAttribute("__iter__") and
  not targetClass.hasAttribute("__getitem__") and
  
  // Exclude special types that might behave like containers
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This membership test may raise an Exception because the $@ could be of non-container class $@.", 
  valueOrigin, "target", targetClass, targetClass.getName()