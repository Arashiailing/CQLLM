/**
 * @name Membership test with a non-container
 * @description Identifies membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, causing runtime TypeError.
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
 * Determines if a control flow node serves as the right operand in a membership test expression.
 * @param rhsNode - Control flow node being evaluated as the right operand
 * @param membershipTestExpr - Comparison expression containing the membership test
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode rhsNode, Compare membershipTestExpr) {
  exists(Cmpop operation, int index |
    membershipTestExpr.getOp(index) = operation and 
    membershipTestExpr.getComparator(index) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  Compare membershipTest, 
  ControlFlowNode rhsOperand, 
  Value pointedValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test expressions and their right operands
  isRightOperandOfMembershipTest(rhsOperand, membershipTest) and
  
  // Analyze the pointed-to value and its class type
  rhsOperand.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = nonContainerClass and
  
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