/**
 * @name Membership test with non-container operand
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand 
 *              operand is a non-container object, which would raise a 'TypeError' at runtime.
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
 * Holds when `rightOperandNode` is the right-hand operand in a membership comparison operation `comparisonExpr`.
 * @param rightOperandNode - Control flow node evaluated as the right operand
 * @param comparisonExpr - Comparison expression containing the membership test
 */
predicate isRhsInMembershipTest(ControlFlowNode rightOperandNode, Compare comparisonExpr) {
  exists(Cmpop operation, int operandIndex |
    comparisonExpr.getOp(operandIndex) = operation and 
    comparisonExpr.getComparator(operandIndex) = rightOperandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedToValue, 
  ClassValue rightOperandClass, 
  ControlFlowNode valueSourceNode
where
  // Identify membership tests and extract right operand
  isRhsInMembershipTest(rightOperandNode, comparisonExpr) and
  
  // Resolve operand value and its class
  rightOperandNode.pointsTo(_, pointedToValue, valueSourceNode) and
  pointedToValue.getClass() = rightOperandClass and
  
  // Validate type inference success
  not Types::failedInference(rightOperandClass, _) and
  
  // Verify non-container characteristics
  (not rightOperandClass.hasAttribute("__contains__") and
   not rightOperandClass.hasAttribute("__iter__") and
   not rightOperandClass.hasAttribute("__getitem__")) and
  not rightOperandClass = ClassValue::nonetype() and
  not rightOperandClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueSourceNode, "target", rightOperandClass, rightOperandClass.getName()