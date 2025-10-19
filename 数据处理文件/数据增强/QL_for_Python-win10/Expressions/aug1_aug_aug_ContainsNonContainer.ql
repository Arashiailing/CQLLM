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
 * Determines if a node serves as the right operand in membership tests.
 * @param targetNode - Control flow node being evaluated
 * @param comparisonNode - Comparison expression containing the membership test
 */
predicate isRightHandSideOfInTest(ControlFlowNode targetNode, Compare comparisonNode) {
  exists(Cmpop operation, int operandIndex |
    comparisonNode.getOp(operandIndex) = operation and 
    comparisonNode.getComparator(operandIndex) = targetNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue nonContainerType, 
  ControlFlowNode originNode
where
  // Step 1: Verify node is right operand of membership test
  isRightHandSideOfInTest(rightOperandNode, comparisonExpr) and
  
  // Step 2: Resolve pointed value and class information
  rightOperandNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = nonContainerType and
  
  // Step 3: Exclude cases with failed type inference
  not Types::failedInference(nonContainerType, _) and
  
  // Step 4: Confirm class lacks container interface methods
  not nonContainerType.hasAttribute("__contains__") and
  not nonContainerType.hasAttribute("__iter__") and
  not nonContainerType.hasAttribute("__getitem__") and
  
  // Step 5: Exclude special pseudo-container types
  not nonContainerType = ClassValue::nonetype() and
  not nonContainerType = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", nonContainerType, nonContainerType.getName()