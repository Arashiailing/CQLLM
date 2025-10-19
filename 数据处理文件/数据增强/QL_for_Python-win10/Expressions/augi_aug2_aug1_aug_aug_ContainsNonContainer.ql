/**
 * @name Membership test with non-container type
 * @description Detects membership tests ('in'/'not in') where the right-hand operand
 *              is a non-container type, potentially causing runtime TypeErrors.
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
 * Identifies when `rightOperandNode` serves as the right-hand side in a membership test
 * within comparison expression `comparisonExpr`.
 * @param rightOperandNode - Control flow node evaluated as the right operand
 * @param comparisonExpr - Comparison expression containing the membership test
 */
predicate isRightHandSideOfInTest(ControlFlowNode rightOperandNode, Compare comparisonExpr) {
  exists(Cmpop membershipOp, int operandPosition |
    comparisonExpr.getOp(operandPosition) = membershipOp and 
    comparisonExpr.getComparator(operandPosition) = rightOperandNode.getNode() and
    (membershipOp instanceof In or membershipOp instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode originNode
where
  // Confirm node is right operand in membership test
  isRightHandSideOfInTest(rightOperandNode, comparisonExpr) and
  
  // Resolve value and class information through points-to analysis
  rightOperandNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = nonContainerClass and
  
  // Filter out cases with failed type inference
  not Types::failedInference(nonContainerClass, _) and
  
  // Verify absence of container interface methods
  (not nonContainerClass.hasAttribute("__contains__") and
   not nonContainerClass.hasAttribute("__iter__") and
   not nonContainerClass.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  (not nonContainerClass = ClassValue::nonetype() and
   not nonContainerClass = Value::named("types.MappingProxyType"))
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ might be of non-container class $@.", 
  originNode, "target", nonContainerClass, nonContainerClass.getName()