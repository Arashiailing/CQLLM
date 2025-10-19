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
 * Identifies nodes serving as right operands in In/NotIn comparisons.
 * @param operandNode - Control flow node being evaluated
 * @param comparisonNode - Comparison expression containing the operation
 */
predicate isRhsOfInTest(ControlFlowNode operandNode, Compare comparisonNode) {
  exists(Cmpop operator, int index |
    comparisonNode.getOp(index) = operator and 
    comparisonNode.getComparator(index) = operandNode.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperand, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode sourceNode
where
  // Verify node is right operand in membership test
  isRhsOfInTest(rightOperand, comparisonExpr) and
  
  // Resolve node's value and class information
  rightOperand.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = valueClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(valueClass, _) and
  
  // Confirm absence of container capabilities
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Filter out special container-like types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", valueClass, valueClass.getName()