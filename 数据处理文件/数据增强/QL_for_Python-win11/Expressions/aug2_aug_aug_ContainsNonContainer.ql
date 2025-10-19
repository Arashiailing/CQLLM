/**
 * @name Membership test with a non-container
 * @description Identifies membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, causing runtime TypeError.
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
  ControlFlowNode rightOperand, 
  Compare comparisonExpr, 
  Value referencedValue, 
  ClassValue nonContainerType, 
  ControlFlowNode originNode
where
  // Verify node is right operand of membership test
  isRightOperandOfMembershipTest(rightOperand, comparisonExpr) and
  
  // Resolve pointed value and class information
  rightOperand.pointsTo(_, referencedValue, originNode) and
  referencedValue.getClass() = nonContainerType and
  
  // Exclude cases with failed type inference
  not Types::failedInference(nonContainerType, _) and
  
  // Confirm class lacks container interface methods
  not nonContainerType.hasAttribute("__contains__") and
  not nonContainerType.hasAttribute("__iter__") and
  not nonContainerType.hasAttribute("__getitem__") and
  
  // Exclude special pseudo-container types
  not nonContainerType = ClassValue::nonetype() and
  not nonContainerType = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", nonContainerType, nonContainerType.getName()