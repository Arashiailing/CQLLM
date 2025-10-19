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
 * @param rightOperand - Node being evaluated as right operand
 * @param comparisonExpr - Comparison expression containing the membership test
 */
predicate isRightHandSideOfInTest(ControlFlowNode rightOperand, Compare comparisonExpr) {
  exists(Cmpop operation, int operandIndex |
    comparisonExpr.getOp(operandIndex) = operation and 
    comparisonExpr.getComparator(operandIndex) = rightOperand.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperand, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode originNode
where
  // Identify membership test operations
  isRightHandSideOfInTest(rightOperand, comparisonExpr) and
  
  // Resolve value and class information
  rightOperand.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = valueClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(valueClass, _) and
  
  // Verify absence of container capabilities
  (not valueClass.hasAttribute("__contains__") and
   not valueClass.hasAttribute("__iter__") and
   not valueClass.hasAttribute("__getitem__")) and
  
  // Exclude special container-like types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", valueClass, valueClass.getName()