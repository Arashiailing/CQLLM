/**
 * @name Membership test with a non-container
 * @description Identifies membership operations (using 'in' or 'not in') where the right-hand side
 *              is a non-container type, potentially leading to a runtime TypeError.
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
 * Holds if `rightOperandNode` is the right operand of a membership test in `comparisonExpr`.
 * @param rightOperandNode - The control flow node representing the right operand.
 * @param comparisonExpr - The comparison expression that contains the membership test.
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode rightOperandNode, Compare comparisonExpr) {
  exists(Cmpop operation, int index |
    comparisonExpr.getOp(index) = operation and 
    comparisonExpr.getComparator(index) = rightOperandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedToValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode originNode
where
  // Identify membership test right operand
  isRightOperandOfMembershipTest(rightOperandNode, comparisonExpr) and
  
  // Resolve type information and source
  rightOperandNode.pointsTo(_, pointedToValue, originNode) and
  pointedToValue.getClass() = nonContainerClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(nonContainerClass, _) and
  
  // Verify absence of container interface methods
  (not nonContainerClass.hasAttribute("__contains__") and
   not nonContainerClass.hasAttribute("__iter__") and
   not nonContainerClass.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types
  not nonContainerClass = ClassValue::nonetype() and
  not nonContainerClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", nonContainerClass, nonContainerClass.getName()