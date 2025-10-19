/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, causing runtime 'TypeError' exceptions.
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
 * Identifies nodes acting as the right operand in membership operations.
 * @param rhsNode - Node being evaluated as right operand
 * @param compareExpr - Comparison expression containing the membership test
 */
predicate isRightHandSideOfInTest(ControlFlowNode rhsNode, Compare compareExpr) {
  exists(Cmpop operation, int operandIndex |
    compareExpr.getOp(operandIndex) = operation and 
    compareExpr.getComparator(operandIndex) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare compareExpr, 
  Value targetValue, 
  ClassValue targetClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test operations
  isRightHandSideOfInTest(rhsNode, compareExpr) and
  
  // Resolve value and class information
  rhsNode.pointsTo(_, targetValue, sourceNode) and
  targetValue.getClass() = targetClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(targetClass, _) and
  
  // Verify absence of container capabilities
  (not targetClass.hasAttribute("__contains__") and
   not targetClass.hasAttribute("__iter__") and
   not targetClass.hasAttribute("__getitem__")) and
  
  // Exclude special container-like types
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select 
  compareExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", targetClass, targetClass.getName()