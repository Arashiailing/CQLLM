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
 * Determines if a node represents the right operand in an In/NotIn comparison.
 * @param rhsNode - The control flow node being evaluated as right operand
 * @param comparisonExpr - The comparison expression containing the operation
 */
predicate isRightHandSideOfInTest(ControlFlowNode rhsNode, Compare comparisonExpr) {
  exists(Cmpop operation, int operandIndex |
    comparisonExpr.getOp(operandIndex) = operation and 
    comparisonExpr.getComparator(operandIndex) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare comparisonExpr, 
  Value value, 
  ClassValue targetClass, 
  ControlFlowNode sourceNode
where
  // Identify In/NotIn operations with rhsNode as right operand
  isRightHandSideOfInTest(rhsNode, comparisonExpr) and
  
  // Resolve the node's pointed value and its class
  rhsNode.pointsTo(_, value, sourceNode) and
  value.getClass() = targetClass and
  
  // Exclude cases where type inference failed
  not Types::failedInference(targetClass, _) and
  
  // Verify the class lacks container-like capabilities
  (not targetClass.hasAttribute("__contains__") and
   not targetClass.hasAttribute("__iter__") and
   not targetClass.hasAttribute("__getitem__")) and
  
  // Exclude special types that might appear as containers
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", targetClass, targetClass.getName()