/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, leading to runtime TypeError.
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
 * Identifies control flow nodes serving as right operands in membership test expressions.
 * @param rightOperand - Control flow node evaluated as the right operand
 * @param membershipExpr - Comparison expression containing the membership test
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode rightOperand, Compare membershipExpr) {
  exists(Cmpop operation, int index |
    membershipExpr.getOp(index) = operation and 
    membershipExpr.getComparator(index) = rightOperand.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  Compare membershipTest, 
  ControlFlowNode rightOperand, 
  Value inferredValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test expressions and their right operands
  isRightOperandOfMembershipTest(rightOperand, membershipTest) and
  
  // Analyze the pointed-to value and its class type
  rightOperand.pointsTo(_, inferredValue, sourceNode) and
  inferredValue.getClass() = nonContainerClass and
  
  // Ensure type inference was successful
  not Types::failedInference(nonContainerClass, _) and
  
  // Verify the class lacks essential container interface methods
  (not nonContainerClass.hasAttribute("__contains__") and
   not nonContainerClass.hasAttribute("__iter__") and
   not nonContainerClass.hasAttribute("__getitem__")) and
  
  // Exclude special pseudo-container types that might bypass the check
  (not nonContainerClass = ClassValue::nonetype() and
   not nonContainerClass = Value::named("types.MappingProxyType"))
select 
  membershipTest, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", nonContainerClass, nonContainerClass.getName()