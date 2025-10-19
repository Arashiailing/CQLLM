/**
 * @name Membership test with non-container operand
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand 
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
 * Identifies right-hand operands in membership comparison operations.
 * @param rightOperandNode - Control flow node evaluated as right operand
 * @param comparisonExpr - Comparison expression containing the membership test
 */
predicate isRhsInMembershipTest(ControlFlowNode rightOperandNode, Compare comparisonExpr) {
  exists(Cmpop operation, int idx |
    comparisonExpr.getOp(idx) = operation and 
    comparisonExpr.getComparator(idx) = rightOperandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value operandValue, 
  ClassValue operandClass, 
  ControlFlowNode sourceOfValue
where
  // Identify membership tests and extract right operand
  isRhsInMembershipTest(rightOperandNode, comparisonExpr) and
  
  // Resolve operand value and its class
  rightOperandNode.pointsTo(_, operandValue, sourceOfValue) and
  operandValue.getClass() = operandClass and
  
  // Validate type inference success
  not Types::failedInference(operandClass, _) and
  
  // Verify non-container characteristics
  (not operandClass.hasAttribute("__contains__") and
   not operandClass.hasAttribute("__iter__") and
   not operandClass.hasAttribute("__getitem__")) and
  not operandClass = ClassValue::nonetype() and
  not operandClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceOfValue, "target", operandClass, operandClass.getName()