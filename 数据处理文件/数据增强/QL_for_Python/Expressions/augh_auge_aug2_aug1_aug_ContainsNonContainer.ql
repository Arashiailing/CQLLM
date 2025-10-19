/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, leading to a runtime 'TypeError'.
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
 * Identifies nodes that serve as the right-hand side operands in In/NotIn comparison operations.
 * @param rightHandSideNode - The control flow node being evaluated as the right operand
 * @param membershipComparison - The comparison expression containing the membership test
 */
predicate isRhsOperandInMembershipTest(ControlFlowNode rightHandSideNode, Compare membershipComparison) {
  exists(Cmpop membershipOperator, int operandIndex |
    membershipComparison.getOp(operandIndex) = membershipOperator and 
    membershipComparison.getComparator(operandIndex) = rightHandSideNode.getNode() and
    (membershipOperator instanceof In or membershipOperator instanceof NotIn)
  )
}

from 
  ControlFlowNode rightHandOperand, 
  Compare membershipComparison, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode sourceNode
where
  // Step 1: Identify membership test operations (e.g., 'x in y' or 'x not in y')
  isRhsOperandInMembershipTest(rightHandOperand, membershipComparison) and
  
  // Step 2: Resolve the value of the right operand and determine its class
  // This uses points-to analysis to track the possible values of the right operand
  rightHandOperand.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = valueClass and
  
  // Step 3: Skip cases where type inference failed to avoid false positives
  not Types::failedInference(valueClass, _) and
  
  // Step 4: Verify the class lacks container capabilities
  // A proper container should implement at least one of these methods
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Step 5: Exclude special types that might behave like containers
  // NoneType and MappingProxyType are special cases that might not implement
  // the standard container methods but still support membership tests
  valueClass != ClassValue::nonetype() and
  valueClass != Value::named("types.MappingProxyType")
select 
  membershipComparison, 
  "This membership test may raise an Exception because the $@ could be of non-container class $@.", 
  sourceNode, "target", valueClass, valueClass.getName()