/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand
 *              is a non-container type, which may cause runtime TypeError.
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
 * Identifies nodes acting as the right operand in membership tests.
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
  ControlFlowNode rightOperand, 
  Compare comparisonExpr, 
  Value targetValue, 
  ClassValue nonContainerType, 
  ControlFlowNode originNode
where
  // Verify node is right operand of membership test
  isRightHandSideOfInTest(rightOperand, comparisonExpr) and
  
  // Resolve pointed value and class information
  rightOperand.pointsTo(_, targetValue, originNode) and
  targetValue.getClass() = nonContainerType and
  
  // Exclude cases with failed type inference
  not Types::failedInference(nonContainerType, _) and
  
  // Confirm class lacks container interface methods
  not (nonContainerType.hasAttribute("__contains__") or 
       nonContainerType.hasAttribute("__iter__") or 
       nonContainerType.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  not (nonContainerType = ClassValue::nonetype() or 
       nonContainerType = Value::named("types.MappingProxyType"))
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", nonContainerType, nonContainerType.getName()