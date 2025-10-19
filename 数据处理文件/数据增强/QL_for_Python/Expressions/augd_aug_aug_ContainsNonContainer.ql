/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
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
 * Identifies nodes acting as the right operand in membership test expressions.
 * @param node - Control flow node being analyzed
 * @param compareNode - Comparison expression containing the membership operation
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode node, Compare compareNode) {
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
  ControlFlowNode sourceLocationNode
where
  // Validate node is right operand of membership test
  isRightOperandOfMembershipTest(rightOperandNode, comparisonExpr) and
  
  // Resolve type information and exclude inference failures
  rightOperandNode.pointsTo(_, pointedValue, sourceLocationNode) and
  pointedValue.getClass() = nonContainerType and
  not Types::failedInference(nonContainerType, _) and
  
  // Verify absence of container interface methods
  (not nonContainerType.hasAttribute("__contains__") and
   not nonContainerType.hasAttribute("__iter__") and
   not nonContainerType.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  (nonContainerType != ClassValue::nonetype() and
   nonContainerType != Value::named("types.MappingProxyType"))
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceLocationNode, "target", nonContainerType, nonContainerType.getName()