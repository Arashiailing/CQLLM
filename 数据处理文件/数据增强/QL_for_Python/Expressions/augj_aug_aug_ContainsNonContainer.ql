/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right operand 
 *              is a non-container type, potentially causing runtime TypeError.
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
 * @param node - Control flow node being evaluated
 * @param compareNode - Comparison expression containing the membership test
 */
predicate isRightHandSideOfInTest(ControlFlowNode node, Compare compareNode) {
  exists(Cmpop operation, int operandIndex |
    compareNode.getOp(operandIndex) = operation and 
    compareNode.getComparator(operandIndex) = node.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue nonContainerType, 
  ControlFlowNode sourceOfValue
where
  // Verify node is right operand of membership test
  isRightHandSideOfInTest(rightOperandNode, comparisonExpr) and
  
  // Resolve pointed value and class information
  rightOperandNode.pointsTo(_, pointedValue, sourceOfValue) and
  pointedValue.getClass() = nonContainerType and
  
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
  sourceOfValue, "target", nonContainerType, nonContainerType.getName()