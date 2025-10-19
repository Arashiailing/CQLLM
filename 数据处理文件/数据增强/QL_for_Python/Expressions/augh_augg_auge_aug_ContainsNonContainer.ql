/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand operand 
 *              is a non-container object, causing runtime 'TypeError'.
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
 * @param rightOperandNode - The control flow node being checked
 * @param comparisonExpr - The comparison expression containing the operation
 */
predicate isRightHandSideOfInTest(ControlFlowNode rightOperandNode, Compare comparisonExpr) {
  exists(Cmpop operationType, int operandIndex |
    comparisonExpr.getOp(operandIndex) = operationType and 
    comparisonExpr.getComparator(operandIndex) = rightOperandNode.getNode() and
    (operationType instanceof In or operationType instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare membershipComparison, 
  Value pointedValue, 
  ClassValue candidateClass, 
  ControlFlowNode originNode
where
  // Validate membership test context
  isRightHandSideOfInTest(rightOperandNode, membershipComparison) and
  
  // Resolve type information
  rightOperandNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = candidateClass and
  
  // Ensure type inference succeeded
  not Types::failedInference(candidateClass, _) and
  
  // Verify missing container capabilities
  not candidateClass.hasAttribute("__contains__") and
  not candidateClass.hasAttribute("__iter__") and
  not candidateClass.hasAttribute("__getitem__") and
  
  // Exclude known non-container types
  not candidateClass = ClassValue::nonetype() and
  not candidateClass = Value::named("types.MappingProxyType")
select 
  membershipComparison, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", candidateClass, candidateClass.getName()