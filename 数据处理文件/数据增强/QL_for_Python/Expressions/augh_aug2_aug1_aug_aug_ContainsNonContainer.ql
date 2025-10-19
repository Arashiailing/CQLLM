/**
 * @name Membership test with non-container type
 * @description Identifies membership tests ('in' or 'not in') where the right-hand operand
 *              belongs to a type that doesn't implement container protocols, potentially
 *              causing runtime TypeErrors.
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
 * Holds if `targetNode` serves as the right operand in a membership test operation
 * ('in' or 'not in') within the comparison expression `expr`.
 * @param targetNode - Control flow node being evaluated as the right operand.
 * @param expr - Comparison expression containing the membership test.
 */
predicate isRightHandSideOfInTest(ControlFlowNode targetNode, Compare expr) {
  exists(Cmpop operation, int operandIndex |
    expr.getOp(operandIndex) = operation and 
    expr.getComparator(operandIndex) = targetNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value referencedValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Validate node is right operand in membership test
  isRightHandSideOfInTest(rightOperandNode, comparisonExpr) and
  
  // Resolve value and class information through points-to analysis
  rightOperandNode.pointsTo(_, referencedValue, sourceNode) and
  referencedValue.getClass() = nonContainerClass and
  
  // Exclude cases with incomplete type inference
  not Types::failedInference(nonContainerClass, _) and
  
  // Verify absence of container protocol methods
  (not nonContainerClass.hasAttribute("__contains__") and
   not nonContainerClass.hasAttribute("__iter__") and
   not nonContainerClass.hasAttribute("__getitem__")) and
  
  // Filter out special pseudo-container types
  (not nonContainerClass = ClassValue::nonetype() and
   not nonContainerClass = Value::named("types.MappingProxyType"))
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ might be of non-container class $@.", 
  sourceNode, "target", nonContainerClass, nonContainerClass.getName()