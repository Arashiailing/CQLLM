/**
 * @name Non-container membership test detection
 * @description Identifies membership checks (e.g., 'element in collection') where the collection 
 *              operand is a non-container type, which may cause a runtime TypeError.
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
 * Holds if `rhsOperand` is the right-hand operand in a membership test expression (In/NotIn)
 * and `membershipTestExpr` is the comparison expression that performs the membership test.
 * @param rhsOperand - The control flow node that serves as the right operand.
 * @param membershipTestExpr - The comparison expression that performs the membership test.
 */
predicate isRightOperandInMembershipTest(ControlFlowNode rhsOperand, Compare membershipTestExpr) {
  exists(Cmpop operator, int index |
    membershipTestExpr.getOp(index) = operator and 
    membershipTestExpr.getComparator(index) = rhsOperand.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsOperandNode, 
  Compare membershipTestExpr, 
  Value inferredTypeValue, 
  ClassValue checkedClass, 
  ControlFlowNode originNode
where
  // Identify membership test expressions and extract their right operand
  isRightOperandInMembershipTest(rhsOperandNode, membershipTestExpr) and
  
  // Perform type analysis on the right operand to determine its class
  rhsOperandNode.pointsTo(_, inferredTypeValue, originNode) and
  inferredTypeValue.getClass() = checkedClass and
  
  // Verify that type inference was successful
  not Types::failedInference(checkedClass, _) and
  
  // Check if the class lacks essential container methods and isn't a recognized container type
  (not checkedClass.hasAttribute("__contains__") and
   not checkedClass.hasAttribute("__iter__") and
   not checkedClass.hasAttribute("__getitem__")) and
  not checkedClass = ClassValue::nonetype() and
  not checkedClass = Value::named("types.MappingProxyType")
select 
  membershipTestExpr, 
  "This membership test may raise an Exception because the $@ could be an instance of non-container class $@.", 
  originNode, "target", checkedClass, checkedClass.getName()