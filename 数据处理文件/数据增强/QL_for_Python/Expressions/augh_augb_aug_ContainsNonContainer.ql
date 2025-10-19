/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand operand 
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
 * Identifies nodes serving as the right operand in In/NotIn comparisons.
 * @param rightOperand - The control flow node being evaluated as right operand
 * @param comparisonExpr - The comparison expression containing the operation
 */
predicate isRightHandSideOfInTest(ControlFlowNode rightOperand, Compare comparisonExpr) {
  exists(Cmpop operator, int index |
    comparisonExpr.getOp(index) = operator and 
    comparisonExpr.getComparator(index) = rightOperand.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue rightOperandClass, 
  ControlFlowNode valueOriginNode
where
  // Identify In/NotIn operations with the node as right operand
  isRightHandSideOfInTest(rightOperandNode, comparisonExpr) and
  
  // Resolve the node's pointed value and its class
  rightOperandNode.pointsTo(_, pointedValue, valueOriginNode) and
  pointedValue.getClass() = rightOperandClass and
  
  // Exclude cases where type inference failed
  not Types::failedInference(rightOperandClass, _) and
  
  // Verify the class lacks container-like capabilities
  (not rightOperandClass.hasAttribute("__contains__") and
   not rightOperandClass.hasAttribute("__iter__") and
   not rightOperandClass.hasAttribute("__getitem__")) and
  
  // Exclude special types that might appear as containers
  not rightOperandClass = ClassValue::nonetype() and
  not rightOperandClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueOriginNode, "target", rightOperandClass, rightOperandClass.getName()