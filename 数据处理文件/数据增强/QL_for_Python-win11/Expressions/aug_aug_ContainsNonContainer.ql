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
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedToValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Step 1: Verify node is right operand of membership test
  isRightHandSideOfInTest(rhsNode, cmpExpr) and
  
  // Step 2: Resolve pointed value and class information
  rhsNode.pointsTo(_, pointedToValue, sourceNode) and
  pointedToValue.getClass() = nonContainerClass and
  
  // Step 3: Exclude cases with failed type inference
  not Types::failedInference(nonContainerClass, _) and
  
  // Step 4: Confirm class lacks container interface methods
  not nonContainerClass.hasAttribute("__contains__") and
  not nonContainerClass.hasAttribute("__iter__") and
  not nonContainerClass.hasAttribute("__getitem__") and
  
  // Step 5: Exclude special pseudo-container types
  not nonContainerClass = ClassValue::nonetype() and
  not nonContainerClass = Value::named("types.MappingProxyType")
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", nonContainerClass, nonContainerClass.getName()