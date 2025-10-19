/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, which would raise a 'TypeError' at runtime.
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
 * Determines if a node serves as the right operand in an In/NotIn comparison.
 * @param rhsNode - The control flow node being evaluated as right operand
 * @param inComparison - The comparison expression containing the operation
 */
predicate isRightHandSideOfInTest(ControlFlowNode rhsNode, Compare inComparison) {
  exists(Cmpop operation, int operandIndex |
    inComparison.getOp(operandIndex) = operation and 
    inComparison.getComparator(operandIndex) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare inComparison, 
  Value pointedValue, 
  ClassValue rhsClass, 
  ControlFlowNode valueOrigin
where
  // Step 1: Identify In/NotIn operations with the node as right operand
  isRightHandSideOfInTest(rhsNode, inComparison) and
  
  // Step 2: Resolve the node's pointed value and its class
  rhsNode.pointsTo(_, pointedValue, valueOrigin) and
  pointedValue.getClass() = rhsClass and
  
  // Step 3: Exclude cases where type inference failed
  not Types::failedInference(rhsClass, _) and
  
  // Step 4: Verify the class lacks container-like capabilities
  (not rhsClass.hasAttribute("__contains__") and
   not rhsClass.hasAttribute("__iter__") and
   not rhsClass.hasAttribute("__getitem__")) and
  
  // Step 5: Exclude special types that might appear as containers
  not rhsClass = ClassValue::nonetype() and
  not rhsClass = Value::named("types.MappingProxyType")
select 
  inComparison, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueOrigin, "target", rhsClass, rhsClass.getName()