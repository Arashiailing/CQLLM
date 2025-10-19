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
 * @param evaluatedNode - The control flow node being checked
 * @param comparisonOperation - The comparison expression containing the operation
 */
predicate isRightHandSideOfInTest(ControlFlowNode evaluatedNode, Compare comparisonOperation) {
  exists(Cmpop operationType, int operandPosition |
    comparisonOperation.getOp(operandPosition) = operationType and 
    comparisonOperation.getComparator(operandPosition) = evaluatedNode.getNode() and
    (operationType instanceof In or operationType instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare membershipComparison, 
  Value pointedToValue, 
  ClassValue valueClassType, 
  ControlFlowNode sourceNode
where
  // Verify node is right operand in membership test
  isRightHandSideOfInTest(rightOperandNode, membershipComparison) and
  
  // Resolve value and class information
  rightOperandNode.pointsTo(_, pointedToValue, sourceNode) and
  pointedToValue.getClass() = valueClassType and
  
  // Exclude cases with unresolved types
  not Types::failedInference(valueClassType, _) and
  
  // Check for missing container capabilities
  not valueClassType.hasAttribute("__contains__") and
  not valueClassType.hasAttribute("__iter__") and
  not valueClassType.hasAttribute("__getitem__") and
  
  // Filter out special non-container types
  not valueClassType = ClassValue::nonetype() and
  not valueClassType = Value::named("types.MappingProxyType")
select 
  membershipComparison, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", valueClassType, valueClassType.getName()